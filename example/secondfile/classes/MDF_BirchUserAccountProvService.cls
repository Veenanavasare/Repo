/*MDF_BirchUser AccountProvService*/
global class MDF_BirchUserAccountProvService implements Database.Batchable < sObject >, Database.Stateful,Schedulable,Database.AllowsCallOuts 
{
    
    global string query;
    Set<Id> accountIds;
    Set<Id> contactIds;
    //Set<Id> userIds;
    //boolean isAccountRun;
    List<Contact> lstContactToUp;
    List<Account> lstAccountToUp;
    //List<User> lstErrorUser;
    List<Contact> lstProcContact;
    List<Account> lstProcAccount;
    //List<User> lstProcUser;
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {   
        try{
        if(accountIds != null && accountIds.size() > 0)
        {
            query = generateSOQLQuery(SFDCConstant.ACCOUNT, true);
        }
        else if(contactIds != null && contactIds.size() > 0)
        {
            query = generateSOQLQuery(SFDCConstant.CONTACT,false);    
        }
        
        return Database.getQueryLocator(query); 
        }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                return null;
            }       
    }     
    /*SchedulableContext*/
    global void execute(SchedulableContext sc){
        try{
        Database.executebatch(this,1); 
        System.abortJob( SC.getTriggerId() ); 
        }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
    }      
    /*BatchableContext*/
    global void execute(Database.BatchableContext BC, List<sObject>scope)
    {   try{
        BirchAccountProvRequestBean bean = new BirchAccountProvRequestBean();
        BirchProvResponseBean resBean = new BirchProvResponseBean();
        BirchProvIntegrationHandler handler = new BirchProvIntegrationHandler();
        String dummyRes = SpecialCharacterBuyflowConstant.CONCAT;
        Set<Id> acctsIds = new Set<Id>();
        Set<Id> admContIds = new Set<Id>();
        List<Contact> lstBirchContacts = new List<Contact>();
        Map<Id, Contact> mapActIDAdmContact = new Map<Id, Contact>();
        Map<Id, List<Contact>> mapActIDOthrContact = new Map<Id, List<Contact>>();
        Map<Id, Account> mapAcctIdAcct = new Map<Id, Account>();
        Map<Id, Lead> mapAcctIdLead = new Map<Id, Lead>();
        List<Lead> lstConvertedLeads = null;
        
        if(accountIds != null && accountIds.size() > 0)
        {
            for(Account acct : (List<Account>)scope)
            {
                acctsIds.add(acct.Id);                
            }
            if(acctsIds != null)
            {
                mapAcctIdAcct = new Map<Id, Account>([Select Id, Name,SFDC_SP_Account_ID__c, BillingPostalCode,BillingState,BillingStreet,BillingCity  from Account where Id=:acctsIds]);
                lstBirchContacts = [select Id,AccountId, Partner_Exchange_User_Name__c,Birch_User_Created__c,Birch_API_Message__c,Birch_User_API_Call_Date__c, FirstName, LastName,Title, Email,Phone,Manage_MDF__c,MDF_Read_Only__c,Account.BillingPostalCode,Account.BillingState,Account.BillingStreet,Account.BillingCity from Contact where AccountId =:acctsIds and (Manage_MDF__c = true OR MDF_Read_Only__c = true)];
                lstConvertedLeads = [Select Id,Billing_Address__c ,Billing_City__c ,Billing_State__c ,Billing_Zip_Code__c,ConvertedContactId,ConvertedOpportunityId,ConvertedAccountId from Lead where ConvertedAccountId = :acctsIds];            
            }
            if(!lstConvertedLeads.isEmpty())
            {
                for(Lead mLead : lstConvertedLeads)
                {
                    mapAcctIdLead.put(mLead.ConvertedAccountId, mLead);
                }
            }            
            if(!lstBirchContacts.isEmpty())
            {
                List<Contact> temLCont;
                for(Contact admCnt : lstBirchContacts)
                {
                    if(admCnt.Manage_MDF__c != null && admCnt.Manage_MDF__c == true && mapActIDAdmContact.get(admCnt.AccountId) == null)
                    {
                        admContIds.add(admCnt.Id);
                        mapActIDAdmContact.put(admCnt.AccountId, admCnt);
                    }
                    else
                    {
                        temLCont = mapActIDOthrContact.get(admCnt.AccountId);
                        if(temLCont == null || temLCont.isEmpty())
                        {
                            temLCont = new List<Contact>();
                            temLCont.add(admCnt);
                            mapActIDOthrContact.put(admCnt.AccountId,temLCont);                            
                        }
                        else
                        {
                            temLCont.add(admCnt);
                            mapActIDOthrContact.put(admCnt.AccountId, temLCont);    
                        }
                    }
                }
            }
            Contact admContact;
            for(Account acct : (List<Account>)scope)
            {
                if(mapActIDAdmContact.get(acct.Id) != null)
                {
                    admContact = mapActIDAdmContact.get(acct.Id);
                    DateTime dt = DateTime.now();
                    bean.convId = 'sfdc-MDF-'+dt.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
                    
                    //bean.convId = ''+Math.random();
                    bean.UserUniqueId =admContact.Partner_Exchange_User_Name__c;
                    bean.Program=SFDCConstant.ATTMDF;
                    bean.Username=admContact.email;
                    bean.LanguageCode=SFDCConstant.EN;
                    bean.Title= admContact.Title == null ? '': admContact.Title;
                    bean.FirstName= admContact.FirstName == null ? '' : admContact.FirstName;
                    bean.Surname=admContact.LastName == null ? '' : admContact.LastName;
                    Account tAccount = mapAcctIdAcct.get(acct.Id);
                    Lead tLead = mapAcctIdLead.get(acct.Id);
                    bean.UserAddress1=(tAccount.BillingStreet!=null && tAccount.BillingStreet != SpecialCharacterBuyflowConstant.CONCAT) ? tAccount.BillingStreet : (tLead != null && tLead.Billing_Address__c != null ? tLead.Billing_Address__c : SpecialCharacterBuyflowConstant.CONCAT);
                    bean.UserAddress2=SpecialCharacterBuyflowConstant.CONCAT;
                    bean.UserAddress3=SpecialCharacterBuyflowConstant.CONCAT;
                    bean.UserCity=tAccount.BillingCity!=null ?tAccount.BillingCity : (tLead != null && tLead.Billing_City__c != null ? tLead.Billing_City__c : SpecialCharacterBuyflowConstant.CONCAT);
                    bean.UserZip=tAccount.BillingPostalCode!=null ? tAccount.BillingPostalCode :(tLead != null && tLead.Billing_Zip_Code__c  != null ? tLead.Billing_Zip_Code__c  : SpecialCharacterBuyflowConstant.CONCAT);
                    bean.UserState=tAccount.BillingState !=null ? tAccount.BillingState:(tLead != null && tLead.Billing_State__c != null ? tLead.Billing_State__c : SpecialCharacterBuyflowConstant.CONCAT);
                    bean.UserCountry=SFDCConstant.USA;
                    bean.UserReportingRegion = SpecialCharacterBuyflowConstant.CONCAT;
                    bean.UserTel= admContact.Phone == null ? SpecialCharacterBuyflowConstant.CONCAT : admContact.Phone ;
                    bean.UserFax=SpecialCharacterBuyflowConstant.CONCAT;
                    bean.UserEmail=admContact.Email;
                    bean.UserMobile=SpecialCharacterBuyflowConstant.CONCAT;
                    bean.PrimaryContactFirstName = admContact.FirstName == null ? SpecialCharacterBuyflowConstant.CONCAT : admContact.FirstName;
                    bean.PrimaryContactSurname = admContact.LastName == null ? SpecialCharacterBuyflowConstant.CONCAT : admContact.LastName;
                    bean.PrimaryContactPosition= SpecialCharacterBuyflowConstant.CONCAT;
                    bean.PrimaryContactEmail=admContact.Email != null ? admContact.Email : SpecialCharacterBuyflowConstant.CONCAT;
                    bean.RoleType = SFDCConstant.ADMIN;    
                    
                    //bean.AccountUniqueId=acct.SFDC_SP_Account_ID__c;
                    bean.AccountUniqueId=acct.Id;// Added to fix the Account Uniqueness Issue 
                    bean.AccountName=acct.Name;
                    bean.PartnerType=SFDCConstant.ACTIVE;
                    bean.PartnerLevel=acct.Current_Tier__c == null ? SpecialCharacterBuyflowConstant.CONCAT : acct.Current_Tier__c;
                    bean.AccountAddress1=tAccount.BillingStreet != null ? tAccount.BillingStreet : (tLead != null && tLead.Billing_Address__c != null ? tLead.Billing_Address__c : SpecialCharacterBuyflowConstant.CONCAT) ;
                    bean.AccountAddress2=SpecialCharacterBuyflowConstant.CONCAT;
                    bean.AccountAddress3=SpecialCharacterBuyflowConstant.CONCAT;
                    bean.AccountCity=tAccount.BillingCity != null ? tAccount.BillingCity : (tLead != null && tLead.Billing_City__c != null ? tLead.Billing_City__c : SpecialCharacterBuyflowConstant.CONCAT) ;
                    bean.AccountZip=tAccount.BillingPostalCode != null ? tAccount.BillingPostalCode : (tLead != null && tLead.Billing_Zip_Code__c != null ? tLead.Billing_Zip_Code__c : SpecialCharacterBuyflowConstant.CONCAT);
                    bean.AccountState=tAccount.BillingState != null ? tAccount.BillingState : (tLead != null && tLead.Billing_State__c != null ? tLead.Billing_State__c : SpecialCharacterBuyflowConstant.CONCAT);
                    bean.AccountCountry=SFDCConstant.USA;
                    
                    
                    bean.AccountReportingRegion=SpecialCharacterBuyflowConstant.CONCAT;
                    
                    
                    bean.AccountTel=SpecialCharacterBuyflowConstant.CONCAT; 
                    bean.AccountFax=SpecialCharacterBuyflowConstant.CONCAT; 
                    bean.AccountMobile=SpecialCharacterBuyflowConstant.CONCAT;  
                    
                   
                  //  if(test.isRunningTest())
                  //      resBean = (BirchProvResponseBean)JSON.deserialize(dummyRes,BirchProvResponseBean.class);
                    if(!test.isRunningTest()){
                        handler.AcctID = admContact.ID;
                        resBean = (BirchProvResponseBean)handler.handleServiceRequest(bean); 
                    }
                    
                   //admContact.Birch_Conversation_Id__c = bean.convId;
                    
                    admContact.Birch_User_API_Call_Date__c = System.now();
                    if(resBean != null)
                    {   
                        if(resBean.MessageText != null && resBean.MessageText.trim() != SpecialCharacterBuyflowConstant.CONCAT)
                        {
                            admContact.Birch_API_Message__c = resBean.MessageText;   
                        }
                        else
                        {
                            admContact.Birch_API_Message__c = resBean.Response.description;   
                        }
                        if(resBean.MessageCode != null)
                        {
                            admContact.Birch_API_Message_Code__c = String.valueOf(resBean.MessageCode);
                        }
                        else
                        {
                            admContact.Birch_API_Message_Code__c = resBean.Response.code;   
                        }
                        if(resBean.MessageCode == 1)
                        {
                            admContact.Birch_User_Created__c = true;
                        }
                        
                    }
                    else
                    {
                        admContact.Birch_API_Message__c = SFDCConstant.UNABLETO_MAKE_WEB_SERVICE_CALL;
                        admContact.Birch_API_Message_Code__c = ATTConstants.FAILURE;
                    }
                    //admContact.Birch_Message_Id__c = resBean.messageId;
                    
                    
                    //if(resBean != null && resBean.MessageCode != null && resBean.MessageCode == 1)
                    if(resBean != null && resBean.MessageCode != null)
                    {
                        if(mapActIDOthrContact != null && mapActIDOthrContact.get(acct.Id) != null)
                        {
                            lstContactToUp.addAll(processOtherContacts(mapAcctIdAcct.get(acct.Id), mapActIDOthrContact.get(acct.Id),mapAcctIdLead.get(acct.Id)));
                        }
                    }

                    lstContactToUp.add(admContact);
                }
            }            
        }
        Set<Id> contIds = new Set<Id>();
        Set<Id> acctIds = new Set<Id>();
        Map<Id, Account> mapIDAccount; 
        Map<Id, List<Contact>> mapOnlyActIDLContact = new Map<Id, List<Contact>>();
        if(contactIds != null && contactIds.size() > 0 )
        {
            for(Contact fp : (List<Contact>)scope)
            {
               contIds.add(fp.Id);
                acctIds.add(fp.AccountId);
            }      
            lstBirchContacts = [select Id, AccountId, Partner_Exchange_User_Name__c, Birch_User_Created__c,Birch_API_Message__c,Birch_User_API_Call_Date__c, FirstName, LastName,Title, Email,Phone,Manage_MDF__c,MDF_Read_Only__c from Contact where Id =:contIds and (Manage_MDF__c = true OR MDF_Read_Only__c = true)];
            mapIDAccount = new Map<Id, Account>([Select Id,Billing_Address__c,Billing_City__c,Billing_Zip_Code__c,Billing_State__c,BillingPostalCode,BillingState,BillingStreet,BillingCity   from Account where Id = :acctIds]);
            List<Contact> temLCont;
            mapOnlyActIDLContact = getAllContactFrAcct(lstBirchContacts);
            /**
            for(Contact admCnt : lstBirchContacts)
            {
                temLCont = mapOnlyActIDLContact.get(admCnt.AccountId);
                if(temLCont == null || temLCont.isEmpty())
                {
                    temLCont = new List<Contact>();
                    temLCont.add(admCnt);
                    mapOnlyActIDLContact.put(admCnt.AccountId,temLCont);                            
                }
                else
                {
                    temLCont.add(admCnt);
                    mapOnlyActIDLContact.put(admCnt.AccountId, temLCont);    
                }
            }**/
            if(!test.isRunningTest()){
            if(!mapOnlyActIDLContact.isEmpty())
            {
                for(String acctId: mapOnlyActIDLContact.keySet())
                {
                    lstContactToUp.addAll(processOtherContacts(mapIDAccount.get(acctId), mapOnlyActIDLContact.get(acctId), mapAcctIdLead.get(acctId)));
                }
            }
          }
        }
        update lstContactToUp;
        BirchwebServiceLogCreation wbCreator = new BirchwebServiceLogCreation();
        wbCreator.insertWeBlogs();
        }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
    }
    /*getAllContactFrAcct*/
    private Map<Id, List<Contact>> getAllContactFrAcct(List<Contact> lstBirchContacts)
    {
        try{
        Map<Id, List<Contact>> retMap = new Map<Id, List<Contact>>();
        List<Contact> temLCont;
        for(Contact admCnt : lstBirchContacts)
        {
            temLCont = retMap.get(admCnt.AccountId);
            if(temLCont == null || temLCont.isEmpty())
            {
                temLCont = new List<Contact>();
                temLCont.add(admCnt);
                retMap.put(admCnt.AccountId,temLCont);                            
            }
            else
            {
                temLCont.add(admCnt);
                retMap.put(admCnt.AccountId, temLCont);    
            }
        }
        return retMap;
        }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                return null;
            }
    }  
        /*processOtherContacts*/
    global List<Contact> processOtherContacts(Account myAcct, List<Contact> lCont, Lead tLead)
    {
        try{
        List<Contact> lRetCont = new List<Contact>();
        //BirchAccountProvRequestBean bean = new BirchAccountProvRequestBean();
        BirchProvResponseBean resBean = new BirchProvResponseBean();
        BirchProvUserIntegrationHandler handler = new BirchProvUserIntegrationHandler();
        String dummyRes = SpecialCharacterBuyflowConstant.CONCAT;
        
        if(myAcct != null && lCont != null && lCont.size() > 0)
        {
            BirchUserProvRequestBean mBean;
            for(Contact cont : lCont)
            {
                mBean = new BirchUserProvRequestBean();
                DateTime dt = DateTime.now();
                mBean.convId =  'sfdc-MDF-'+dt.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
                mBean.Username =cont.email != null ? cont.email : SpecialCharacterBuyflowConstant.CONCAT;
                mBean.Zip =myAcct.BillingPostalCode != null ? myAcct.BillingPostalCode : (tLead != null && tLead.Billing_Zip_Code__c  != null ? tLead.Billing_Zip_Code__c  : SpecialCharacterBuyflowConstant.CONCAT);
                mBean.state = myAcct.BillingState != null ? myAcct.BillingState : (tLead != null && tLead.Billing_State__c != null ? tLead.Billing_State__c : SpecialCharacterBuyflowConstant.CONCAT);
                mBean.Address1 = (myAcct.BillingStreet != null && myAcct.BillingStreet != SpecialCharacterBuyflowConstant.CONCAT )? myAcct.BillingStreet : (tLead != null && tLead.Billing_Address__c != null ? tLead.Billing_Address__c : SpecialCharacterBuyflowConstant.CONCAT);
                mBean.Address2 = SpecialCharacterBuyflowConstant.CONCAT;
                mBean.Address3 = SpecialCharacterBuyflowConstant.CONCAT;
                mBean.City = myAcct.BillingCity != null ? myAcct.BillingCity:(tLead != null && tLead.Billing_City__c != null ? tLead.Billing_City__c : SpecialCharacterBuyflowConstant.CONCAT);
                mBean.Country = SFDCConstant.USA;
                mBean.Email = cont.Email;
                mBean.Fax = SpecialCharacterBuyflowConstant.CONCAT;
                mBean.FirstName = cont.FirstName == null ? SpecialCharacterBuyflowConstant.CONCAT : cont.FirstName ;
                mBean.LanguageCode = SFDCConstant.EN;
                mBean.Mobile = SpecialCharacterBuyflowConstant.CONCAT;
                mBean.Program =SFDCConstant.ATTMDF;
                mBean.ReportingRegion =SpecialCharacterBuyflowConstant.CONCAT;
                //mBean.State =myAcct.BillingState != null ? myAcct.BillingState : SpecialCharacterBuyflowConstant.CONCAT ;
                mBean.Surname = cont.LastName == null ? SpecialCharacterBuyflowConstant.CONCAT : cont.LastName;
                mBean.Tel = cont.Phone == null ? SpecialCharacterBuyflowConstant.CONCAT : cont.Phone;
                mBean.Title = SpecialCharacterBuyflowConstant.CONCAT;
                mBean.UniqueId =cont.Partner_Exchange_User_Name__c;
                
                if(cont.Birch_User_Created__c != null && cont.Birch_User_Created__c == true)
                {
                    mBean.Action =SFDCConstant.U;
                }
                else
                {
                    mBean.Action =SFDCConstant.A;   
                }
                
                
                List<BirchUserProvRequestBean.cls_UserAccountAccess> tempUserAccess = new List<BirchUserProvRequestBean.cls_UserAccountAccess>();
                BirchUserProvRequestBean.cls_UserAccountAccess uAAccess = new BirchUserProvRequestBean.cls_UserAccountAccess();
                uAAccess.AccountUniqueId = myAcct.Id;
                if(cont.Manage_MDF__c != null && cont.Manage_MDF__c == true)
                {
                    uAAccess.RoleType = SFDCConstant.ADMIN;
                }
                else
                {
                    uAAccess.RoleType = SFDCConstant.REQUESTER;
                }
                
                uAAccess.DefaultAccount = true;
                
                tempUserAccess.add(uAAccess);
                mBean.UserAccountAccess = tempUserAccess;
                
                /*if(!test.isRunningTest())
                    resBean = (BirchProvResponseBean)JSON.deserialize(dummyRes,BirchProvResponseBean.class);*/
                if(!test.isRunningTest())
                {
                    handler.ContID = cont.ID;
                    resBean = (BirchProvResponseBean)handler.handleServiceRequest(mBean); 
                }
                
                
                cont.Birch_User_API_Call_Date__c = System.now();
                
                if(resBean != null)
                {
                    if(resBean.MessageText != null && resBean.MessageText.trim() != SpecialCharacterBuyflowConstant.CONCAT)
                    {
                        cont.Birch_API_Message__c = resBean.MessageText;   
                    }
                    else
                    {
                        cont.Birch_API_Message__c = resBean.Response.description;   
                    }
                    if(resBean.MessageCode != null)
                    {
                        cont.Birch_API_Message_Code__c = String.valueOf(resBean.MessageCode);
                    }
                    else
                    {
                        cont.Birch_API_Message_Code__c = resBean.Response.code;   
                    }
                    if(resBean.MessageCode == 1)
                    {
                        cont.Birch_User_Created__c = true;
                    }
                    
                   // cont.Birch_Message_Id__c = resBean.messageId;
                }
                else
                {
                    cont.Birch_API_Message__c = SFDCConstant.UNABLETO_MAKE_WEB_SERVICE_CALL;
                    cont.Birch_API_Message_Code__c = ATTConstants.FAILURE;
                }
                lRetCont.add(cont);
            } 
        }
        
        return lRetCont;
        }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                return null;
            }
    }
    /*MDF_BirchUserAccountProvService*/
    global MDF_BirchUserAccountProvService(Set<Id> acctIds, Set<Id> contIds)
    {
        this.accountIds = acctIds;
        this.contactIds = contIds;
        //this.userIds = usrIds;
        
//        isAccountRun = isAccRun;
        
        lstContactToUp = new List<Contact>();
        lstAccountToUp = new List<Account>();
   //     lstErrorUser = new List<User>();
        
        //lstProcAccount = lAccount;
        //lstProcContact= lContact;
        //lstProcUser= lUser;
        
    }
    // Finish the Batch Job
     /*finish*/
    global void finish(Database.BatchableContext bcMain) 
    {
        if(!lstAccountToUp.isEmpty())
        {
            
        }
        if(!lstContactToUp.isEmpty())
        {
            
        }
    }
    /*
* generate Query
* @Param : String objectName
*/
    private String generateSOQLQuery(String objectName, boolean isAccount){
        Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get(objectName).getDescribe().Fields.getMap();
        String soql = 'Select ';
        for(String fd : fieldsMap.keySet()){
            soql +=  fd + ',';
        } 
        
        if(soql.trim().endsWith(',')){
            soql = soql.substring(0, soql.lastIndexOf(','));
        }
        if(isAccount)
        {
            soql += ' from ' + objectName + ' where (Id = : accountIds) ';    
        }
        else
        {
            soql += ' from ' + objectName + ' where (Id = : contactIds) ';    
        }
        
        soql += ' order by LastModifiedDate ' ;
        return soql;
    }   
}