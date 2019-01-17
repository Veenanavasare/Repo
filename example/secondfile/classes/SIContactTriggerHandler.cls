/* Name: SIContactTriggerHandler
Description:
*/
public class  SIContactTriggerHandler extends SITriggerOperations.SITriggerImpl 
{  

     public boolean isExecuted;
     
     /*
       Component Name : MissingAccountInformationException 
       Description : 
     
     */
     public class MissingAccountInformationException extends Exception{}
     
     /*
       Component Name : MissingFirstNameException 
       Description : 

     */
     public class MissingFirstNameException extends Exception{}     
     
     /*
       Component Name : MissingLastNameException 
       Description : 
 
     */
     public class MissingLastNameException extends Exception{}  
    
     /*
       Component Name :MissingEmailException
       Description :        
     */
     public class MissingEmailException extends Exception{}  
     public static boolean afterUpdateFlag = false;
     public boolean flag;

   
     /* Name: SIContactTriggerHandler
        Description:Default cons
    */
     public SIContactTriggerHandler() 
     {
        isExecuted = true;
        flag=false;
     }
    
     
     /* Name: onBeforeInsert
Description:An Overridden method.
*/
     public override boolean onBeforeInsert(SObject[] newObjects) 
     {
        try 
        { 
           flag= displyDummyAccount(newObjects,flag); 
           
            leadAddressToContact(newObjects);
            autoPopulateForCommunityEnabledUsers(newObjects);
            //US314475:Streamline selection of Portal Administrator
            updatePortalAdminOnRoleSelection(newObjects);
            insertPortalAdminRoleBasedonATOMFields(newObjects);
            updatePEUserNameOnContact( newObjects );
           
        } 
        catch(Exception excep) 
        {
            isExecuted = false;
            throw excep;
        }
        return isExecuted;
     }
    
   
 /* Name: onAfterInsert
Description:An Overridden method.
*/  
     public override boolean onAfterInsert(SObject[] newObjects) 
     {
        try 
        {
            primaryFRCValidation(newObjects,false);  
           createUserOnContactCreationForCommunityEnabledUsers(newObjects) ;          
            afterUpdateFlag = true;
                       
            if(label.Auto_Provisioning_Status.equalsIgnoreCase(UtilityConstant.TrueVar)) 
            {    
                createUserOnContactCreation(newObjects); 
            }
            list<Contact> conList =newObjects;
            
            // Added isConverted check as part of US752286
            for(Contact con : conList)
            {
                if(con.isconverted__c){
                    sendAcctUsertoBD(newObjects); 
                    syncInfoWithBirchOnInsert(newObjects);
                    sendContactToNetExam(newObjects,newObjects,false);
                }
            }
        } 
        catch(Exception excep) 
        {
            isExecuted = false;
            throw excep;
        }
        return isExecuted;
    }
    
    //BD User Story for user creation on after insert
/* 
 Name: sendAcctUsertoBD
 Description: 
 */ 
    public void sendAcctUsertoBD(SObject[] insertObjects){
        
    list<contact> conList = insertObjects;
    Set<id> contset = new Set<id>();
    Set<id> contsetToPass = new Set<id>();
    
    
    for(Contact con:conList){  
          
        contset.add(con.id);
        
    }
    for(Contact con:[select id,accountid,account.BD_Company_ID__c,BD_Trigger_Date_Time__c,BD_User_ID__c from Contact where ID IN: contset]){
       if(string.ISBLANK(con.BD_User_ID__c) && !string.ISBLANK(con.account.BD_Company_ID__c) && (con.BD_Trigger_Date_Time__c == NULL)){
        contsetToPass.add(con.id);
        }
    }
    try{
    if(contsetToPass.size()>0){
        BDAccountUserCreationWebServAPIHelper.sendUserDetailstoBDhelper(contsetToPass);
        }
        }
     catch(Exception e){
         ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
     }
    }
   
     /* Name: onBeforeUpdate
Description:An Overridden method.
*/
    public override boolean onBeforeUpdate(SObject[] oldObjects,SObject[] newObjects,Map<Id,SObject> newObjectsMap )
    {
        try
        {  
            displyDummyAccount(newObjects);
            leadAddressToContact(newObjects);
            updatePortalAdminOnRoleSelection(newObjects);
            autoPopulateForCommunityEnabledUsers(newObjects);
            updatePortalAdminRoleBasedonATOMFields(oldObjects,newObjects);
            updatePEUserNameOnContact( newObjects );
            updateNewPEUsernameOnContact(oldObjects,newObjects);
            updateBillingAndServiceStatusOnContact(oldObjects,newObjects);
            list<Contact> conList =newObjects;
            for(Contact con : conList)
            {
                if((String.isEmpty(con.User_Role__c))||(con.User_Role__c == SpecialCharacterConstant.CONCAT) || (con.User_Role__c == null)){
                    con.User_Role__c = UtilityConstant.STUDENT;
                }
                if((String.isEmpty(con.NetExam_User_Type__c))||(con.NetExam_User_Type__c == SpecialCharacterConstant.CONCAT) || (con.NetExam_User_Type__c == null)){
                    con.NetExam_User_Type__c = UtilityConstant.SOLUTIONPROVIDER;
                }    
            }
        }
        catch(Exception e)
        {
           
            isExecuted=false;
            throw e;
        }
        return isExecuted;    
    }
    
    
     
     /* Name: onAfterUpdate
        Description:An Overridden method.
     */ 
     public override boolean onAfterUpdate(SObject[] oldObjects,SObject[] newObjects,Map<Id,SObject> newObjectsMap )
     {
        try{
            primaryFRCValidation(newObjects,true);
             if(!Test.isRunningTest()){
                if(label.Auto_Provisioning_Status.equalsIgnoreCase(UtilityConstant.TrueVar)){    
                    updateUserOnContactUpdation(oldObjects,newObjects);
                }
            } else {
                updateUserOnContactUpdation(oldObjects,newObjects);
            }
            updateATOMFieldsOnUser(oldObjects,newObjects);
            updateUserOnContactUpdationForCommunityEnabledUsers(oldObjects,newObjects);
            
            list<Contact> conList =newObjects;
             for(Contact con : conList)
            {
                if(con.isconverted__c){
            if(afterUpdateFlag == false){
                sendAcctUsertoBD(newObjects);
            }
            syncInfoWithBirch(oldObjects,newObjects);
            sendContactToNetExam(oldObjects,newObjects,true);
                }
            }
            
        }
        catch(Exception e){
           
            isExecuted=false;
            throw e;
        }
        return isExecuted;    
    }
 /* Name: displyDummyAccount
Description:
*/ 
   private void displyDummyAccount (SObject[] newObjects)
   {
      
        list<Contact> NewList= newObjects;
        ID accID = Label.Dummy_Account_Id;
        for(Contact updateContact :NewList)
        {
           if(updateContact.recordtypeId == System.Label.Lead_Contact_Record_Type)
           {
                updateContact.AccountId =accID;
           }
        }
    }
     /* Name: displyDummyAccount
Description:
*/ 
        private boolean displyDummyAccount(SObject[] newObjects, Boolean flag)
   {
        list<Contact> newList= newObjects;
        ID accID = Label.Dummy_Account_Id;
        for(Contact updateContact :newList)
        {
           if(updateContact.recordtypeId == System.Label.Lead_Contact_Record_Type)
           {
                updateContact.AccountId =accID;
                
           }else{flag=true;}
        }
        return flag;
    }
    
 /* Name: leadAddressToContact
Description:Copying Lead Address to Contact address
*/  
    public void leadAddressToContact(SObject[] newObjects)
    {
        try{
        list<Contact> newList= newObjects;
        set<ID> leadId = new set<Id>();
        for(Contact con:newList)
        {
           if(flag){ con.isconverted__c=true;}
            leadId.add(con.lead__c);
        }flag=false;
        if( leadId.size() > 0 ) {
            list<Lead> leadList = [select Id,Street,City,PostalCode,State,Country from lead where lead.Id IN :leadId];
            for(Contact con:newList)
            {
                if(con.Copy_Address_from_Lead__c)
                {
                    for(Lead lead:leadList)
                    {
                        if(con.lead__c==lead.Id)
                        {
                            if(lead.Street!=null && lead.City!=null && lead.PostalCode!=null && lead.State!=null && lead.Country!=null)
                            {
                                con.MailingStreet=lead.Street;
                                con.MailingCity=lead.City;
                                con.MailingPostalCode=lead.PostalCode;
                                con.MailingState =lead.State;
                                con.MailingCountry=lead.Country;
                                con.Copy_Address_from_Lead__c=false;
                            }
                            else
                            {
                                con.addError(BuyflowConstant.Lead_company_address_should_not_be_null_in_order_to_Copy_Address_from_Lead);
                            }
                        }
                    }
                }
            }
        }
    }
    catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
} 
  /* Name: primaryFRCValidation
Description:
*/   
    public void primaryFRCValidation(SObject[] newObjects,Boolean isUpdate) 
    {
        try{
          List<Contact> newContactList = newObjects;
          List<Contact> LeadContactlist = new List<Contact>();
          List<Contact> AccContactlist = new List<Contact>();
          List<Id> leadIdlist = new List<Id>();
          List<Id> accIdlist =new List<ID>();
          Integer leadPC,leadRC;
          
          Map<ID,Boolean> leadPrimaryMap = new Map<ID,Boolean>();
          Map<ID,Boolean> leadMainConcMap = new Map<ID,Boolean>();

          
          //Get the list of Opty records and Existing Site Address List
          for(Contact a:newContactList)
          {
           if(a.Lead__c!=null && a.AccountID==label.Dummy_Account_Id){
                leadIdlist.add(a.Lead__c);
           }else if(a.AccountId!=null && a.AccountID!=label.Dummy_Account_Id ){
                accIdlist.add(a.AccountID);
           }
          }
          
          if(leadIdlist!=null){
          
            LeadContactlist = [Select s.Lead__c, s.Primary_Contact__c,s.Role__c,s.Id From Contact s
                              where s.Lead__c IN: leadIdlist];
                              
                 for(Id LL:leadIdlist){
                    leadPC=0;leadRC=0;
                    for(Contact ex:LeadContactlist){
                        if(LL==ex.Lead__c){
                            if(ex.Primary_Contact__c){
                                leadPC++;
                            }
                            if(leadPC>2){
                                LeadPrimaryMap.put(LL,true);
                            }
                            if(ex.Role__c!=null){
                                if(ex.Role__c.contains(UtilityConstant.MAINCONTACT)){
                                    leadRC++;
                                }
                            if(leadRC>1){
                                LeadMainConcMap.put(LL,true);
                                }
                            }
                        }
                    }
               }
                      
          }
          if(accIdlist!=null){
                AccContactlist = [Select s.AccountId, s.Primary_Contact__c,s.Role__c,s.Id,s.ATOM_Account__c From Contact s
                              where s.AccountId IN: accIdlist and s.ATOM_Account__c = True];
            
                 for(Id ACC:accIdlist){
                    for(Contact con:AccContactlist){
                        con.Community_Enabled__c = True;
                    }
               }
          }
           
           for(Contact cc:newContactList){
                if(LeadPrimaryMap.get(cc.Lead__c)!=null && cc.Primary_Contact__c){
                    cc.Primary_Contact__c.addError(UtilityConstant.TWOPORTAL_ADMINISTRATORS_ALREADY_EXIST_FOR_THIS_ORGANIZATION_x);
                }
                 if(LeadMainConcMap.get(cc.Lead__C)!=null){
                    if(cc.Role__c!=null){
                        if(cc.Role__c.contains(UtilityConstant.MAINCONTACT)){
                        cc.Role__c.addError(UtilityConstant.AMAIN_CONTACT_ALREADY_EXISTS_FOR_THIS_ORGANIZATION_x);
                        }
                    }
                }
           }
     }
     catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
} 
  /* Name: sendContactToNetExam
Description:
*/    
     public void sendContactToNetExam(SObject[] oldObjects, SObject[] newObjects, Boolean isUpdate)
     {
        try{
        list <Contact> newContacts = newObjects;
        list <Contact> oldcontacts = oldObjects;
        list <Contact> toNetExamList = new list <Contact>();
        
        if(!newContacts.isEmpty() && newContacts != null)
        {
            if(!isUpdate)
            {
                for(Contact cnt : newContacts)
                {
                    if(cnt.Email != null && cnt.LastName != null && cnt.PE_User_ID__c != null && cnt.Partner_Type__c != UtilityConstant.WHOLESALE && cnt.Partner_Type__c != UtilityConstant.ENABLEMENTRESOURCE)
                    {
                        toNetExamList.add(cnt);
                    }
                }
            }
            else
            {
                for(Integer i=0 ; i< newContacts.size(); i++)
                {
                    if(oldcontacts[i].Email==null || oldcontacts[i].LastName == null || oldcontacts[i].PE_User_ID__c==null)
                    {
                        if(newContacts[i].Email != null && newContacts[i].LastName != null && newContacts[i].PE_User_ID__c != null && newContacts[i].Partner_Type__c != UtilityConstant.WHOLESALE && newContacts[i].Partner_Type__c != UtilityConstant.ENABLEMENTRESOURCE && newContacts[i].Partner_Type__c != null )
                        {
                            toNetExamList.add(newContacts[i]);
                        }
                    }
                    else
                    {
                        if(newContacts[i].Email != null && newContacts[i].LastName != null && newContacts[i].PE_User_ID__c != null && newContacts[i].Partner_Type__c != UtilityConstant.WHOLESALE && newContacts[i].Partner_Type__c != UtilityConstant.ENABLEMENTRESOURCE && newContacts[i].Partner_Type__c != null )
                        {
                            if(oldcontacts[i].Email != newContacts[i].Email || oldcontacts[i].PE_User_ID__c != newContacts[i].PE_User_ID__c)
                            {
                                toNetExamList.add(newContacts[i]);
                            }
                        }
                    }
                    // Chnages were made to send contact to netexam if the community enabled check box is true.
                    if(oldcontacts[i].Community_Enabled__c== False  && newContacts[i].Community_Enabled__c == True) {
                      toNetExamList.add(newContacts[i]);             
                            
                    }
                }
            }
        }
        if(!toNetExamList.isEmpty() && toNetExamList != null && toNetExamList.size()<=10 && ((10 - Limits.getFutureCalls()) >= toNetExamList.size()) && !test.isRunningTest())
        {
            for(contact myContact:toNetExamList)
            {
                String firstName = SpecialCharacterConstant.CONCAT;
                String lastName = SpecialCharacterConstant.CONCAT;
                String email = SpecialCharacterConstant.CONCAT;
                String accountId = SpecialCharacterConstant.CONCAT;
            
                //Saving off to string vars so that we can safely do 
                firstName = (String)myContact.FirstName;
                lastName = (String)myContact.LastName;
                email = (String)myContact.Email;    
                accountId = (String)myContact.AccountId;
                                
                if((10 - Limits.getFutureCalls()) > 0)
                {
                                                    
                    //Do data validation on all fields that will be an issue if they wait for the webservice        
                    if(firstName == null)
                    {
                        throw new MissingFirstNameException(UtilityConstant.FIRSTNAME_IS_REQUIRED);
                    }
                                                        
                    if(lastname == null)
                    {    
                        throw new MissingLastNameException(UtilityConstant.LASTNAME_IS_REQUIRED);
                                    }
                
                    if(email == null)
                    {    
                        throw new MissingEmailException(UtilityConstant.EMAILIS_REQUIRED);
                                }
                    if(accountId == null)
                    {    
                        throw new MissingAccountInformationException (UtilityConstant.CONTACTIS_NOT_ASSOCIATED_WITH_AN_ACCOUNT);
                    }   
                    System.debug('=====??????'+accountId);                  
                    NetExamWebServiceAPIHelper82.SendContactFromTrigger(
                        myContact.Id, 
                        firstName, 
                        lastName, 
                        email,
                        accountId
                    );
                }
                else
                {
                    break;
                }
            }   
        }           
    }
    catch(Exception e){
        ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
    }
} 
    
   
    /* Name: createUserOnContactCreation
Description:This method is used for the Auto Provisioning of Customer Community Users
*/
    public void createUserOnContactCreation(SObject[] newObjects)
    {
        
        List<Contact> newContactList=newObjects;
        Set<Id> accId = new Set<Id>();
        Map<Id,String> accMap= new Map<Id,String>();
        
        Database.DMLOptions dlo = new Database.DMLOptions();
        dlo.EmailHeader.triggerAutoResponseEmail = false;
        
        for(Contact c:newContactList){  
            accId.add(c.AccountID);
        }
      
        for(Account acc: [SELECT Id,Name from Account WHERE Id IN : accId]){  
            accMap.put(acc.ID,acc.Name);
        }
      
        List<User> userList =new List<User>();
            
        //insertion of user on creation of contact
        for(Contact c:newContactList)
        {  
            if(c.PE_User_ID__c!=null && c.Email!=null && c.Partner_Exchange_User_Name__c!=null)
            {
                //insert new user
                User newUser = new User();
                newUser.FirstName=c.FirstName;
                newUser.LastName=c.LastName;
                newUser.Email=c.Email;
                newUser.Phone=c.Phone;
                newUser.Title=c.Title;
                newUser.Street=c.MailingStreet;
                newUser.City=c.MailingCity;
                newUser.Street=c.MailingStreet;                
                newUser.PostalCode=c.MailingPostalCode;
                newUser.Country=c.MailingCountry; 
                newUser.CompanyName=accMap.get(c.AccountID);
                newUser.Username=c.Partner_Exchange_User_Name__c+UtilityConstant.DOT+c.PE_User_ID__c+label.Environment_Name;
                newUser.isActive=true;
                newUser.UserPreferencesHideS1BrowserUI=false;
             
                newUser.ProfileId = label.Community_User_Id ;
                newUser.ContactId=c.id;
                if(c.FirstName.length()>8)
                {
                    newUser.Alias=c.FirstName.substring(0,8);
                }
                else
                {
                     newUser.Alias=c.FirstName;
                }
                newUser.CommunityNickname=c.LastName+c.PE_User_ID__c;
                newUser.TimeZoneSidKey=SIConstants.TIMEZONESIDKEY;
                newUser.LocaleSidKey= SIConstants.LANGUAGESIDKEY;
                newUser.LanguageLocaleKey=SIConstants.LANGUAGELOCALEKEY;
                newUser.EmailEncodingKey=SIConstants.EMAILENCODINGKEY;
                newUser.setOptions(dlo);
                newUser.FederationIdentifier=c.PE_User_ID__c; 
                userList.add(newUser);
            }
         }
                    
         try
         {
             database.insert(userList);
         } 
         catch(Exception e)
         {
             ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
         }
     }
    
    
 /* Name: updateUserOnContactUpdation
Description:This method is used for the Auto Provisioning of Customer Community Users
*/       
    public void updateUserOnContactUpdation(SObject[] oldObjects, SObject[] updatedObjects)
    { 
    
        List<User> userList =new List<User>();
        List<Contact> contactOldList= oldObjects;
        List<Contact> contactNewList= updatedObjects;
        List<Contact> contactIds= new List<Contact>();
            
        List<User> userInsert =new List<User>();
        List<User> userUpdate =new List<User>();
            
        Map<Id,User> userContactMap=new Map<Id,User>();
              
        Set<Id> accId = new Set<Id>();
        Map<Id,String> accMap= new Map<Id,String>();
        
        Database.DMLOptions dlo = new Database.DMLOptions();
        dlo.EmailHeader.triggerAutoResponseEmail = false;
      
        for(Contact c:contactNewList){  
            accId.add(c.AccountID);
        }
      
        for(Account acc: [SELECT Id,Name from Account WHERE Id IN : accId]){  
            accMap.put(acc.ID,acc.Name);
        }
   
        for(integer i=0;i<ContactNewList.size();i++){
            if((contactOldList[i].PE_User_ID__c!=contactNewList[i].PE_User_ID__c || contactOldList[i].Email!=contactNewList[i].Email || contactOldList[i].Partner_Exchange_User_Name__c!=contactNewList[i].Partner_Exchange_User_Name__c) && contactNewList[i].PE_User_ID__c!=null && contactNewList[i].Email!=null && contactNewList[i].Partner_Exchange_User_Name__c!=null){
                contactIds.add(contactNewList[i]);
            }
        }    
        
        userList=[Select ID,ContactId,Email,FederationIdentifier from User where ContactId IN:contactIds AND UserType=:SIConstants.User_Type_Customer AND IsActive=:true];
       
        for(User u:userList){
            userContactMap.put(u.ContactId,u);  
        } 

        for(integer i=0;i<contactIds.size();i++){
            if((contactOldList[i].PE_User_ID__c!=contactNewList[i].PE_User_ID__c || contactOldList[i].Email!=contactNewList[i].Email || contactOldList[i].Partner_Exchange_User_Name__c!=contactNewList[i].Partner_Exchange_User_Name__c) && contactNewList[i].PE_User_ID__c!=null && contactNewList[i].Email!=null && contactNewList[i].Partner_Exchange_User_Name__c!=null){
                if(userContactMap.keySet().contains(contactIds[i].Id)){
                    User existUser = userContactMap.get(contactIds[i].Id);
                    if((existUser.FederationIdentifier != contactIds[i].PE_User_ID__c)||(existUser.Email != contactIds[i].Email))
                    {
                        existUser.FederationIdentifier = contactIds[i].PE_User_ID__c;  
                        existUser.Email = contactIds[i].Email;
                        userUpdate.add(existUser);
                    }
                }
                else{
                    Contact c = contactIds[i];
                    User newUser = new User();
                    newUser.FirstName=c.FirstName;
                    newUser.LastName=c.LastName;
                    newUser.Email=c.Email;
                    newUser.Phone=c.Phone;
                    newUser.Title=c.Title;
                    newUser.Street=c.MailingStreet;
                    newUser.City=c.MailingCity;
                    newUser.Street=c.MailingStreet;                
                    newUser.PostalCode=c.MailingPostalCode;
                    newUser.Country=c.MailingCountry; 
                    newUser.CompanyName=accMap.get(c.AccountID);
                    newUser.Username=c.Partner_Exchange_User_Name__c+UtilityConstant.DOT+c.PE_User_ID__c+label.Environment_Name;
                    newUser.isActive=true;
                    newUser.UserPreferencesHideS1BrowserUI=false;
                 
                    newUser.ProfileId = label.Community_User_Id;
                    newUser.ContactId=c.id;
                    if(c.FirstName.length()>8)
                    {
                        newUser.Alias=c.FirstName.substring(0,8);
                    }
                    else
                    {
                         newUser.Alias=c.FirstName;
                    }
                    newUser.CommunityNickname=c.LastName+c.PE_User_ID__c;
                    newUser.TimeZoneSidKey=SIConstants.TIMEZONESIDKEY;
                    newUser.LocaleSidKey= SIConstants.LANGUAGESIDKEY;
                    newUser.LanguageLocaleKey=SIConstants.LANGUAGELOCALEKEY;
                    newUser.EmailEncodingKey=SIConstants.EMAILENCODINGKEY;
                    newUser.setOptions(dlo);
                    newUser.FederationIdentifier=c.PE_User_ID__c; 
                    userInsert.add(newUser);
                }
            }
        }

        try {
            if(userInsert!=null && !userInsert.isEmpty()){
                database.insert(userInsert);
             }
             if(userUpdate!=null && !userUpdate.isEmpty()){ 
                database.update(userUpdate);
            }
            
        } catch(Exception e){
          ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));  
        }
    }

     
  /* Name: updatePortalAdminOnRoleSelection
Description:Streamline selection of Portal Administrator: This function is used to update portal admin check box based on the value of contact role.
*/    
    public void updatePortalAdminOnRoleSelection( SObject[] newObjects ) 
    {
        try{
        list<Contact> newConList = newObjects;
        for( Contact newCon : newConList ) 
        {
            if( newCon.Role__c != null ) 
            {
                if(newCon.Role__c.Contains(UtilityConstant.PORTALADMINISTRATOR)) 
                {
                    newCon.Primary_Contact__c = true;
                }
                else 
                {
                    newCon.Primary_Contact__c = false;
                }
            }
            else 
            {
                newCon.Primary_Contact__c = false;
            }
             
        }
    }
    catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}
    
     
      /* Name: autoPopulateForCommunityEnabledUsers
Description:This method is used to populate the Partner Exchange Username and Partner Exchange User Id for a Partner User
*/ 
    public void autoPopulateForCommunityEnabledUsers(SObject[] newObjects)
    {
        try{
        list<Contact> newConList = newObjects;
        list<Contact> partnerUserIdList= new list<Contact>();
        Decimal highestPEUserId;
        list<Contact> selectedCon = new list<Contact>();
        list<Contact> conWithCommunityEnabled = new list<Contact>();
        
        partnerUserIdList= [ SELECT PE_User_Id_Formula__c FROM Contact where PE_User_Id_Formula__c != null ORDER BY PE_User_Id_Formula__c DESC LIMIT 1 ];
        if( partnerUserIdList.size() > 0 && partnerUserIdList != null )
        {
            highestPEUserId = partnerUserIdList[0].PE_User_Id_Formula__c;
        }
        else{
            highestPEUserId = 1;
        }
       
        for( Contact newCon : newConList ) 
        {
            if( newCon.Community_Enabled__c == True) 
            {
                selectedCon.add(newCon);
                if( newCon.PE_User_ID__c == null )
                {              
                     highestPEUserId = highestPEUserId + 1;
                     newCon.PE_User_ID__c = string.valueof(highestPEUserId);
                }
            }
        }          
    }
    catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}
    
   Public List<String> upperCaseCharacters=SIConstants.UPPERCASECHARACTERS;
    Public List<String> numbericCase=SIConstants.NUMBERIC;
    Public List<String> lowerCaseCharacter=SIConstants.LOWERCASECHARACTERS; 
    Public List<String> specialCaseCharacter=SIConstants.SPECIAL;
    Public String txtdata=SpecialCharacterConstant.CONCAT;
    Public String txtLower=SpecialCharacterConstant.CONCAT;
    Public String txtNumeric=SpecialCharacterConstant.CONCAT;
    Public String txtSpecial=SpecialCharacterConstant.CONCAT;
    
    // Methods for generating Password combination
    //Logic starts here 
    
/* 
 Name: randomUppercase
 Description: 
 */ 
    public Integer randomUppercase(){
        try{
        Integer random = Math.Round(Math.Random()* upperCaseCharacters.Size());
        if(random == upperCaseCharacters.size()){
            random--;
        }
        return random;
    }
    catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
return null;
}
}
/* 
 Name: randomSpecialcase
 Description: 
 */ 
    public Integer randomSpecialcase(){
        try{
        Integer random = Math.Round(Math.Random()* specialCaseCharacter.Size());
        if(random == specialCaseCharacter.size()){
            random--;
        }
        return random;
    }
    catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
return null;
}
}
/* 
 Name: randomNumericcase
 Description: 
 */ 
    public Integer randomNumericcase(){
        try{
        Integer random = Math.Round(Math.Random()* numbericCase.Size());
        if(random == numbericCase.size()){
            random--;
        }
        return random;
    }
    catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
return null;
}
}
/* 
 Name: randomLowercase
 Description: 
 */ 
    public Integer randomLowercase(){
        try{
        Integer random = Math.Round(Math.Random()* lowerCaseCharacter.Size());
        if(random == lowerCaseCharacter.size()){
            random--;
        }
        return random;
    }
    catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
return null;
}
}
/* 
 Name: getUpperChar
 Description: 
 */ 
     public String getUpperChar(){
         try{
     txtdata=SpecialCharacterConstant.CONCAT;
       for(integer i=0;i<2;i++)
       {
         txtdata+=upperCaseCharacters [randomUppercase()];
         
       }
      return txtdata.trim();
    }
    catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
return null;
}
}
/* 
 Name: getNumericChar
 Description: 
 */ 
    public String getNumericChar(){
        try{
     txtdata=SpecialCharacterConstant.CONCAT;
       for(integer i=0;i<2;i++)
       {
         txtdata+=numbericCase[randomNumericcase()];
         
       }
      return txtdata.trim();
    }
    catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
return null;
}
}
/* 
 Name: getLowerChar
 Description: 
 */ 
    public String getLowerChar(){
        try{
     txtdata=SpecialCharacterConstant.CONCAT;
       for(integer i=0;i<4;i++)
       {
         txtdata+=lowerCaseCharacter[randomLowercase()];
         
       }
      return txtdata.trim();
    }
    catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
return null;
}
}
/* 
 Name: getSpecialChar
 Description: 
 */ 
    public String getSpecialChar(){
        try{
     txtdata=SpecialCharacterConstant.CONCAT;
       for(integer i=0;i<2;i++)
       {
         txtdata+=specialCaseCharacter[randomSpecialcase()];
         
        }
        return txtdata.trim();
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            return null;
        }
    }
    
    // Logic Ends  
           
    /* 
       Name : createUserOnContactCreationForCommunityEnabledUsers
       Description:  This is to insert Partner User for Community Enabled Contacts on Creation And
                     Password Format = 2 UpperCase + 4 LowerCase + 2 Special Character + 2 Numeric   
    */
    public void createUserOnContactCreationForCommunityEnabledUsers(SObject[] newObjects)
    { 
    
        List<Contact> newContactList=newObjects;
        Boolean isCheckAdminControl = false;
        Admin_Control__c admin = new Admin_Control__c();
        list<Admin_Control__c> adminList = new list<Admin_Control__c>();
        Integer usedPartnerLicenses = 0;
        for(Contact c:newContactList)
        {  
        
            if(c.PE_User_ID__c!=null && c.Email!=null && c.Partner_Exchange_User_Name__c!=null && c.Community_Enabled__c == True && c.ATOM_Account__c ==  True)
            {
                isCheckAdminControl = true;
                break;
            }
        }
        if(isCheckAdminControl){    
            
            adminList = [SELECT total_Partner_Communities_licenses__c, used_Partner_licenses__c, remaining_Partner_licenses__c from Admin_Control__c LIMIT 1];
            usedPartnerLicenses = [SELECT COUNT() from User where UserType=:SIConstants.User_Type_Partner AND isActive=:true];
            if (adminList.size() > 0 && adminList != null)
            {
                adminList[0].used_Partner_licenses__c = usedPartnerLicenses;
                adminList[0].remaining_Partner_licenses__c = adminList[0].total_Partner_Communities_licenses__c - adminList[0].used_Partner_licenses__c;
            }
            
        }
        Database.DMLOptions dlo = new Database.DMLOptions();
        dlo.EmailHeader.triggerAutoResponseEmail = false;
        
        List<User> userList = new List<User>();
            
         for(Contact c:newContactList)
        {          
            if(c.PE_User_ID__c!=null && c.Email!=null && c.Partner_Exchange_User_Name__c!=null && c.Community_Enabled__c == True && c.ATOM_Account__c ==  True)
            {
                //insert new user
                User newUser = new User();
                newUser.FirstName=c.FirstName;
                newUser.LastName=c.LastName;
                newUser.Email=c.Email;
                newUser.Phone=c.Phone;
                newUser.Title=c.Title;
                newUser.Street=c.MailingStreet;
                newUser.City=c.MailingCity;
                newUser.Street=c.MailingStreet;                
                newUser.PostalCode=c.MailingPostalCode;
                newUser.Country=c.MailingCountry; 
                newUser.CompanyName= c.Account_Name__c;  
                newUser.Username=c.Partner_Exchange_User_Name__c+UtilityConstant.DOT+c.PE_User_ID__c+label.Environment_Name;
                newUser.UserPreferencesHideS1BrowserUI=false;
                newUser.ProfileId = label.Partner_UserID;
                newUser.ContactId=c.id;
                if (adminList.size() > 0 && adminList != null)
                {
                    if(adminList[0].remaining_Partner_licenses__c > 0){
                        newUser.isActive=true;
                    }
                    else{ 
                        newUser.isActive=false; 
                        }
                }  
                if(c.FirstName.length()>8)
                {
                    newUser.Alias=c.FirstName.substring(0,8);
                }
                else
                {
                     newUser.Alias=c.FirstName;
                }
                newUser.CommunityNickname=c.LastName+c.PE_User_ID__c;
                newUser.TimeZoneSidKey=SIConstants.TIMEZONESIDKEY;
                newUser.LocaleSidKey= SIConstants.LANGUAGESIDKEY;
                newUser.LanguageLocaleKey=SIConstants.LANGUAGELOCALEKEY;
                newUser.EmailEncodingKey=SIConstants.EMAILENCODINGKEY;
                newUser.FederationIdentifier = c.Partner_Exchange_User_Name__c.toLowerCase();
                String password=getUpperChar()+getSpecialChar()+getNumericChar()+getLowerChar();
                newUser.Temppassword__c=password;
                
                newUser.Create_Modify_Profile__c = c.Create_Modify_Profile__c;
                newUser.Begin_Quote__c = c.Begin_Quote__c;
                newUser.Approve_Contracts__c = c.Approve_Contracts__c;
                newUser.Manage_MDF__c = c.Manage_MDF__c;
                newUser.MDF_Read_Only__c = c.MDF_Read_Only__c;
                newUser.Service_Assurance__c = c.Service_Assurance__c;
                newUser.Manage_Billing__c = c.Manage_Billing__c;
                newUser.Provider_Directory__c = c.Provider_Directory__c;              
                newUser.setOptions(dlo);
                userList.add(newUser);
             } 
         }
                    
        try
        {
            database.insert(userList);
        }          
        catch(Exception e)
        {
           ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e)); 
        }
    }
    
    /*
      Method Name : updateUserOnContactUpdationForCommunityEnabledUsers
      Method Description:   1. This is to insert Partner user for Community Enabled Contacts on Updates 
                            2. Password Format = 2 UpperCase + 3 LowerCase + 3 Special Character + 2 Numeric   
    */    
     public void updateUserOnContactUpdationForCommunityEnabledUsers(SObject[] oldObjects, SObject[] updatedObjects)
     {
         
        Admin_Control__c admin = new Admin_Control__c();
        list<Admin_Control__c> adminList = new list<Admin_Control__c>();
        List<User> userList =new List<User>();
        List<Contact> contactOldList= oldObjects;
        List<Contact> contactNewList= updatedObjects;
        List<Contact> contactIds= new List<Contact>();
            
        List<User> userInsert =new List<User>();
        List<User> userUpdate =new List<User>();
            
        Map<Id,User> userContactMap=new Map<Id,User>();
              
        Set<Id> accId = new Set<Id>();
        Map<Id,String> accMap= new Map<Id,String>();
        Integer usedPartnerLicenses = 0;
        for(integer i=0;i<ContactNewList.size();i++){
            if((contactOldList[i].Community_Enabled__c!=contactNewList[i].Community_Enabled__c) && contactNewList[i].Community_Enabled__c == True && contactNewList[i].ATOM_Account__c == True) {
                contactIds.add(contactNewList[i]);
            }
        }    
        if(contactIds != null && contactIds.size()>0){
            adminList = [SELECT total_Partner_Communities_licenses__c, used_Partner_licenses__c, remaining_Partner_licenses__c from Admin_Control__c LIMIT 1];
            usedPartnerLicenses = [SELECT COUNT() from User where UserType=:SIConstants.User_Type_Partner AND isActive=:true];
            if (adminList.size() > 0 && adminList != null)
            {
                adminList[0].used_Partner_licenses__c = usedPartnerLicenses;
                adminList[0].remaining_Partner_licenses__c = adminList[0].total_Partner_Communities_licenses__c - adminList[0].used_Partner_licenses__c;
            }
            
            
     
            Database.DMLOptions dlo = new Database.DMLOptions();
            dlo.EmailHeader.triggerAutoResponseEmail = false;
          
            for(Contact c:contactNewList){  
                accId.add(c.AccountID);
            }
          
            for(Account acc: [SELECT Id,Name from Account WHERE Id IN : accId]){  
                accMap.put(acc.ID,acc.Name);
            }
       
           
            for(integer i=0;i<contactIds.size();i++)
            {
                Contact c = contactIds[i];
                User newUser = new User();
                newUser.FirstName=c.FirstName;
                newUser.LastName=c.LastName;
                newUser.Email=c.Email;
                newUser.Phone=c.Phone;
                newUser.Title=c.Title;
                newUser.Street=c.MailingStreet;
                newUser.City=c.MailingCity;
                newUser.Street=c.MailingStreet;                
                newUser.PostalCode=c.MailingPostalCode;
                newUser.Country=c.MailingCountry; 
                newUser.CompanyName=accMap.get(c.AccountID);
                newUser.Username=c.Partner_Exchange_User_Name__c+UtilityConstant.DOT+c.PE_User_ID__c+label.Environment_Name;
                
                newUser.UserPreferencesHideS1BrowserUI=false;
                newUser.ProfileId = label.Partner_UserID;
                newUser.ContactId=c.id;
                if (adminList.size() > 0 && adminList != null)
                {
                    if(adminList[0].remaining_Partner_licenses__c > 0){
                        newUser.isActive=true;
                    }
                    else{
                        newUser.isActive=false; 
                        }
                }        
                if(c.FirstName.length()>8)
                {
                    newUser.Alias=c.FirstName.substring(0,8);
                }
                else
                {
                     newUser.Alias=c.FirstName;
                }
                newUser.CommunityNickname=c.LastName+c.PE_User_ID__c;
                newUser.TimeZoneSidKey=SIConstants.TIMEZONESIDKEY;
                newUser.LocaleSidKey= SIConstants.LANGUAGESIDKEY;
                newUser.LanguageLocaleKey=SIConstants.LANGUAGELOCALEKEY;
                newUser.EmailEncodingKey=SIConstants.EMAILENCODINGKEY;
                newUser.FederationIdentifier = c.Partner_Exchange_User_Name__c.toLowerCase();  
                String password=getUpperChar()+getSpecialChar()+getNumericChar()+getLowerChar();
                newUser.Temppassword__c = password;
                
                newUser.Create_Modify_Profile__c = c.Create_Modify_Profile__c;
                newUser.Begin_Quote__c = c.Begin_Quote__c;
                newUser.Approve_Contracts__c = c.Approve_Contracts__c;
                newUser.Manage_MDF__c = c.Manage_MDF__c;
                newUser.MDF_Read_Only__c = c.MDF_Read_Only__c;
                newUser.Service_Assurance__c = c.Service_Assurance__c;
                newUser.Manage_Billing__c = c.Manage_Billing__c;
                newUser.Provider_Directory__c = c.Provider_Directory__c;
                newUser.setOptions(dlo);
                userInsert.add(newUser); 
            }
         
            try  
            {
                if(userInsert!=null && !userInsert.isEmpty())
                {
                    database.insert(userInsert);
                }
            } 
            catch(Exception e)
            {
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
        }
    }
    
    
     /* Name: updateATOMFieldsOnUser
        Description:Method to update the ATOM fields on Partner User based on that on Contact
     */
    public void updateATOMFieldsOnUser(SObject[] oldObjects, SObject[] updatedObjects)
    { 
    
        List<User> userList =new List<User>();
        List<User> userUpdate =new List<User>();
        List<Contact> contactOldList= oldObjects;
        List<Contact> contactNewList= updatedObjects;
        List<Contact> contactIds= new List<Contact>();
              
        Map<Id,User> userContactMap=new Map<Id,User>();
 
        for(integer i=0; i<ContactNewList.size(); i++)
        {
            if( contactOldList[i].Partner_Exchange_User_Name__c!= contactNewList[i].Partner_Exchange_User_Name__c || contactOldList[i].FirstName != contactNewList[i].FirstName || contactOldList[i].LastName != contactNewList[i].LastName || contactOldList[i].Email != contactNewList[i].Email || contactOldList[i].Phone != contactNewList[i].Phone || contactOldList[i].Create_Modify_Profile__c != contactNewList[i].Create_Modify_Profile__c || contactOldList[i].Begin_Quote__c !=contactNewList[i].Begin_Quote__c || contactOldList[i].Approve_Contracts__c != contactNewList[i].Approve_Contracts__c || contactOldList[i].Manage_MDF__c != contactNewList[i].Manage_MDF__c || contactOldList[i].MDF_Read_Only__c != contactNewList[i].MDF_Read_Only__c || contactOldList[i].Provider_Directory__c != contactNewList[i].Provider_Directory__c || contactOldList[i].Service_Assurance__c != contactNewList[i].Service_Assurance__c || contactOldList[i].Manage_Billing__c != contactNewList[i].Manage_Billing__c)
            {
                contactIds.add(contactNewList[i]);
            }
        }    
        
        userList = [ SELECT Id, FederationIdentifier, isActive, FirstName, LastName, Email, Phone, ContactId, Create_Modify_Profile__c, Begin_Quote__c, Approve_Contracts__c, Manage_MDF__c, MDF_Read_Only__c, Service_Assurance__c, Manage_Billing__c, Provider_Directory__c FROM User WHERE ContactId IN:contactIds AND UserType=:SIConstants.User_Type_Partner AND IsActive=:true];
        
        for(User u:userList)
        {
            userContactMap.put(u.ContactId,u);  
        } 

        for(integer i=0; i<contactIds.size(); i++)
        {
            if( contactOldList[i].Partner_Exchange_User_Name__c!= contactNewList[i].Partner_Exchange_User_Name__c || contactOldList[i].FirstName != contactNewList[i].FirstName || contactOldList[i].LastName != contactNewList[i].LastName || contactOldList[i].Email != contactNewList[i].Email || contactOldList[i].Phone != contactNewList[i].Phone || contactOldList[i].Create_Modify_Profile__c != contactNewList[i].Create_Modify_Profile__c || contactOldList[i].Begin_Quote__c !=contactNewList[i].Begin_Quote__c || contactOldList[i].Approve_Contracts__c != contactNewList[i].Approve_Contracts__c || contactOldList[i].Manage_MDF__c != contactNewList[i].Manage_MDF__c || contactOldList[i].MDF_Read_Only__c != contactNewList[i].MDF_Read_Only__c || contactOldList[i].Provider_Directory__c != contactNewList[i].Provider_Directory__c || contactOldList[i].Service_Assurance__c != contactNewList[i].Service_Assurance__c || contactOldList[i].Manage_Billing__c != contactNewList[i].Manage_Billing__c)
            {
                if(userContactMap.keySet().contains(contactIds[i].Id))
                {
                    User existUser = userContactMap.get(contactIds[i].Id);
                    existUser.FederationIdentifier = contactIds[i].Partner_Exchange_User_Name__c.toLowerCase(); 
                    existUser.FirstName = contactIds[i].FirstName;
                    existUser.LastName = contactIds[i].LastName ;
                    existUser.Email= contactIds[i].Email;
                    existUser.Phone= contactIds[i].Phone;
                    existUser.Create_Modify_Profile__c = contactIds[i].Create_Modify_Profile__c; 
                    existUser.Begin_Quote__c = contactIds[i].Begin_Quote__c;
                    existUser.Approve_Contracts__c = contactIds[i].Approve_Contracts__c;
                    existUser.Manage_MDF__c = contactIds[i].Manage_MDF__c;
                    existUser.MDF_Read_Only__c = contactIds[i].MDF_Read_Only__c;
                    existUser.Service_Assurance__c = contactIds[i].Service_Assurance__c;
                    existUser.Manage_Billing__c = contactIds[i].Manage_Billing__c;
                    existUser.Provider_Directory__c = contactIds[i].Provider_Directory__c;
                    userUpdate.add(existUser);
                }
            }
        }

        try 
        {
            if(userUpdate!=null && !userUpdate.isEmpty())
            { 
                update userUpdate;
            }
        } 
        catch(Exception e)
        {
           ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e)); 
        }
    }
  
    
     /* Name: updateATOMFieldsOnUser
Description:Method to insert or remove the Portal Administrator role based on the Permissions provided and update the permissions if the user is a Portal Administrator
*/
    public void insertPortalAdminRoleBasedonATOMFields(SObject[] newObjects)
    {
        try{
        List<Contact> contactList = newObjects;
        Boolean blockPermissionUpdate = True;
        system.debug('inside method');
        for(Contact con : contactList)
        {
            
            if( con.Create_Modify_Profile__c == True && con.Begin_Quote__c == True && con.Approve_Contracts__c == True && ( con.Manage_MDF__c == True || con.MDF_Read_Only__c == True ) && con.Provider_Directory__c == True && con.Service_Assurance__c == True && con.Manage_Billing__c == True )
            {
                if (con.Role__c == null)
                {
                    con.Role__c =UtilityConstant.PORTALADMINISTRATOR;
                    con.Primary_Contact__c = true;
                    blockPermissionUpdate = False;
                }
                else if(con.Role__c.indexOf(UtilityConstant.PORTALADMINISTRATOR) < 0)
                {
                    con.Role__c +=UtilityConstant.PORTAL_ADMINISTRATOR;
                    con.Primary_Contact__c = true;
                    blockPermissionUpdate = False;
                }
            } 
            
            
            if( con.Role__c != null && con.Role__c.Contains(UtilityConstant.PORTALADMINISTRATOR) && blockPermissionUpdate == True )
            {
                con.Create_Modify_Profile__c = True;
                con.Begin_Quote__c = True;
                con.Approve_Contracts__c = True;
                if(!con.Basic__c){
                con.Manage_MDF__c = True;
                con.MDF_Read_Only__c = False;}
                con.Service_Assurance__c = True;
                con.Manage_Billing__c = True;
                con.Provider_Directory__c = True;
                con.Primary_Contact__c = True;
            }
            
            
            
            
        }
        
        
        
        CheckBillingAndServiceStatusOnCreation(contactList);
    }
    catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}
    
    
    /* Name: updateATOMFieldsOnUser
Description:Method to update the Portal Administrator field based on update of permissions
*/
    public void updatePortalAdminRoleBasedonATOMFields(SObject[] oldObjects, SObject[] updatedObjects)
    {  
    try{    
        List<Contact> contactOldList= oldObjects;
        List<Contact> contactNewList= updatedObjects;
        List<Contact> contactIds= new List<Contact>();
        List<User> usrlst = new List<User>();
        List<User> userPresentOnContactList = new List<User>();
        Boolean blockPermissionUpdate = True;
        
        Integer portalAdminCount;
        List<Id> accIdlist =new List<ID>();
        List<Contact> accContactList = new List<Contact>();
        map<id,user> userConMap = new map<id,user>();  
        Map<ID,Boolean> accPortalAdminMap = new Map<ID,Boolean>();
        Set<ID> portalAdminSet = new Set<ID>();
    
        for(Contact con : contactNewList)
        {
            if(con.AccountId!=null)
            {
                accIdlist.add(con.AccountID);
            }
        }
          
        if( accIdlist!=null )
        {
            accContactList = [Select Primary_Contact__c,Partner_Exchange_Status__c, AccountId From Contact where accountId IN: accIdlist];
            integer countUserActive = 0;            
            usrlst = [select IsActive,Community_Role__c,contactid  from user where accountid IN: accIdlist];
            userPresentOnContactList = [select IsActive,Community_Role__c,contactid  from user where contactid =: contactNewList[0].id ];
            for(user u:usrlst){
                if(u.contactid != null)
                {
                    userConMap.put(u.contactid,u);
                }    
            }
                              
            for( Id accId : accIdlist )
            {
                portalAdminCount = 0;
                for( Contact con : accContactList )
                {
                    if( accId == con.accountId )
                    {
                        
                        if(con.Primary_Contact__c && userConMap.get(con.id) != null && userConMap.get(con.id).IsActive == true && userConMap.get(con.id).Community_Role__c == BuyflowConstant.Admin){
                            portalAdminCount ++;
                            portalAdminSet.add(con.id);
                        }
                    }
                }
                if(portalAdminCount == 1 || portalAdminCount == 2){
                    accPortalAdminMap.put(accId,true);
                }
                else{
                   accPortalAdminMap.put(accId,false); 
                }
            }      
        }
        

        for(integer i=0;i<ContactNewList.size();i++)
        {
            if(contactOldList[i].Create_Modify_Profile__c != contactNewList[i].Create_Modify_Profile__c || contactOldList[i].Begin_Quote__c !=contactNewList[i].Begin_Quote__c || contactOldList[i].Approve_Contracts__c != contactNewList[i].Approve_Contracts__c || contactOldList[i].Manage_MDF__c != contactNewList[i].Manage_MDF__c || contactOldList[i].MDF_Read_Only__c != contactNewList[i].MDF_Read_Only__c || contactOldList[i].Provider_Directory__c != contactNewList[i].Provider_Directory__c || contactOldList[i].Role__c != contactNewList[i].Role__c || contactOldList[i].Service_Assurance__c != contactNewList[i].Service_Assurance__c || contactOldList[i].Manage_Billing__c != contactNewList[i].Manage_Billing__c)
            {
                contactIds.add(contactNewList[i]);
            }
        }    
 
        for(integer i=0;i<contactIds.size();i++)
        {
            if(contactNewList[i].Basic__c==False){        
            if(contactOldList[i].Create_Modify_Profile__c != contactNewList[i].Create_Modify_Profile__c || contactOldList[i].Begin_Quote__c !=contactNewList[i].Begin_Quote__c || contactOldList[i].Approve_Contracts__c != contactNewList[i].Approve_Contracts__c || contactOldList[i].Manage_MDF__c != contactNewList[i].Manage_MDF__c || contactOldList[i].MDF_Read_Only__c != contactNewList[i].MDF_Read_Only__c || contactOldList[i].Provider_Directory__c != contactNewList[i].Provider_Directory__c || contactOldList[i].Service_Assurance__c != contactNewList[i].Service_Assurance__c || contactOldList[i].Manage_Billing__c != contactNewList[i].Manage_Billing__c)
            {
                if( contactNewList[i].Create_Modify_Profile__c == True && contactNewList[i].Begin_Quote__c == True && contactNewList[i].Approve_Contracts__c == True && ( contactNewList[i].Manage_MDF__c == True || contactNewList[i].MDF_Read_Only__c == True ) && contactNewList[i].Provider_Directory__c == True && contactNewList[i].Service_Assurance__c == True && contactNewList[i].Manage_Billing__c == True)
                {
                    if (contactNewList[i].Role__c == null)
                    {
                        contactNewList[i].Role__c = UtilityConstant.PORTALADMINISTRATOR;
                        contactNewList[i].Primary_Contact__c = true;
                        blockPermissionUpdate = False;
                    }
                    else if(contactNewList[i].Role__c.indexOf(UtilityConstant.PORTALADMINISTRATOR) < 0)
                    {
                        contactNewList[i].Role__c +=UtilityConstant.PORTAL_ADMINISTRATOR;
                        contactNewList[i].Primary_Contact__c = true;
                        blockPermissionUpdate = False;
                    }
                }
                else if ( contactNewList[i].Create_Modify_Profile__c == False || contactNewList[i].Begin_Quote__c == False ||( contactNewList[i].Manage_MDF__c == False && contactNewList[i].MDF_Read_Only__c == False ) || contactNewList[i].Approve_Contracts__c == False  || contactNewList[i].Provider_Directory__c == False || contactNewList[i].Service_Assurance__c == false || contactNewList[i].Manage_Billing__c == false)
                {
                    if( accPortalAdminMap.get(contactNewList[i].accountId) == true && portalAdminSet.contains(contactNewList[i].id) && contactNewList[i].Primary_Contact__c == True &&  userPresentOnContactList != null && userPresentOnContactList.size()>0)
                    {
                         contactNewList[i].addError(BuyflowConstant.Update_not_allowed_There_should_be_atleast_two_Portal_Administrator_for_an_SP_Account );
                    }
                    else
                    {
                        if(contactNewList[i].Role__c != null && contactNewList[i].Role__c.indexOf(UtilityConstant.PORTALADMINISTRATOR) != -1)
                        { 
                            contactNewList[i].Role__c = contactNewList[i].Role__c.replaceAll(UtilityConstant.SIVARConst_PORTAL_ADMINISTRATOR_x,SpecialCharacterConstant.CONCAT);
                            contactNewList[i].Primary_Contact__c = false;
                        }
                    }
                }
            }
            }
             else{
            if(contactOldList[i].Create_Modify_Profile__c != contactNewList[i].Create_Modify_Profile__c || contactOldList[i].Begin_Quote__c !=contactNewList[i].Begin_Quote__c || contactOldList[i].Approve_Contracts__c != contactNewList[i].Approve_Contracts__c ||  contactOldList[i].Provider_Directory__c != contactNewList[i].Provider_Directory__c)
            {
                if( contactNewList[i].Create_Modify_Profile__c == True && contactNewList[i].Begin_Quote__c == True && contactNewList[i].Approve_Contracts__c == True &&  contactNewList[i].Provider_Directory__c == True)
                {
                    if (contactNewList[i].Role__c == null)
                    {
                        contactNewList[i].Role__c = BuyflowConstant.Portal_Administrator;
                        contactNewList[i].Primary_Contact__c = true;
                        blockPermissionUpdate = False;
                    }
                    else if(contactNewList[i].Role__c.indexOf(BuyflowConstant.Portal_Administrator) < 0)
                    {
                        contactNewList[i].Role__c +=BuyflowConstant.Portal_Administrator1;
                        contactNewList[i].Primary_Contact__c = true;
                        blockPermissionUpdate = False;
                    }
                }
                else if ( contactNewList[i].Create_Modify_Profile__c == False || contactNewList[i].Begin_Quote__c == False || contactNewList[i].Approve_Contracts__c == False || contactNewList[i].Provider_Directory__c == False)
                {
                    if( accPortalAdminMap.get(contactNewList[i].accountId) == true && portalAdminSet.contains(contactNewList[i].id) && contactNewList[i].Primary_Contact__c == True && userPresentOnContactList != null && userPresentOnContactList.size()>0)
                    {   
                        contactNewList[i].addError(' Update not allowed!!! There should be at least two Portal Administrator for an SP Account!!!');
                    }
                    else
                    {
                        if(contactNewList[i].Role__c != null && contactNewList[i].Role__c.indexOf(BuyflowConstant.Portal_Administrator) != -1)
                        { 
                            contactNewList[i].Role__c = contactNewList[i].Role__c.replaceAll(BuyflowConstant.Portal_Administrator1,SpecialCharacterConstant.CONCAT);
                            contactNewList[i].Primary_Contact__c = false;
                        }
                    }
                }
            }
            }
            if(contactOldList[i].Role__c != contactNewList[i].Role__c || contactNewList[i].Role__c == null){
                if( accPortalAdminMap.get(contactNewList[i].accountId) == true && portalAdminSet.contains(contactNewList[i].id) )
                    {
                        if (contactNewList[i].Role__c != null){
                            if(!contactNewList[i].Role__c.contains( BuyflowConstant.Portal_Administrator) &&  userPresentOnContactList != null && userPresentOnContactList.size()>0){
                                contactNewList[i].addError(BuyflowConstant.Update_not_allowed_There_should_be_atleast_two_Portal_Administrator_for_an_SP_Account );
                            }
                        }
                        else{
                            contactNewList[i].addError(BuyflowConstant.Update_not_allowed_There_should_be_atleast_two_Portal_Administrator_for_an_SP_Account);
                        }
                        
                    }
            }
            
            if( contactNewList[i].Role__c != null )
            {
                if( (contactOldList[i].Role__c != contactNewList[i].Role__c) && contactNewList[i].Role__c.Contains(UtilityConstant.PORTALADMINISTRATOR) && blockPermissionUpdate == True)
                {  
                    contactNewList[i].Create_Modify_Profile__c = True;
                    contactNewList[i].Begin_Quote__c = True;
                    contactNewList[i].Approve_Contracts__c = True;
                    if(!contactNewList[i].Basic__c){
                    contactNewList[i].Manage_MDF__c = True;
                    contactNewList[i].MDF_Read_Only__c = False;}
                    contactNewList[i].Service_Assurance__c = True;
                    contactNewList[i].Manage_Billing__c = True;
                    contactNewList[i].Provider_Directory__c = True;
                    contactNewList[i].Primary_Contact__c = True;
                }
            }
            
            
        }
    }
    catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}
    
    /*
    Method name: updatePEUserNameOnContact
    Retuen Type: Void
    Parameters: updatedObject
    Business Logic: This function is used to update 
    
    
    
    
     on contact based on contact first and last name.
    */
    public void updatePEUserNameOnContact( SObject[] updatedObjects ){
    
        list<Contact> newlistContact = updatedObjects;
        set<String> peUserName = new set<String>();
        list<Contact> selectedContacts = new list<Contact>();
        map<String, Integer> peUserNameCount = new map<String, Integer>();
        map<String, String> peUserNameDupCheck = new map<String, String>();
        set<Id> selectedConID = new set<Id>();
        try{
            for( Contact con : newlistContact ) {
                if( (con.Partner_Exchange_User_Name__c == null || con.Partner_Exchange_User_Name__c == SpecialCharacterConstant.CONCAT)&& con.Community_Enabled__c ) {
                    peUserName.add( con.PEUserNameFormula__c.toLowerCase() );
                    selectedContacts.add(con);
                    selectedConID.add(con.Id);
                    

                }
            }
            if( selectedContacts.size() > 0 && selectedContacts != null ) {
                list<Contact> contactWithPEName = [ select Id, PEUserNameFormula__c,Partner_Exchange_User_Name__c from Contact where PEUserNameFormula__c IN :peUserName and ID NOT IN:selectedConID and Partner_Exchange_User_Name__c != null ];
                for( Contact peCon : contactWithPEName  ) {
                  peUserNameDupCheck.put(peCon.Partner_Exchange_User_Name__c,peCon.Partner_Exchange_User_Name__c);
                    if( peUserNameCount.get(peCon.PEUserNameFormula__c.toLowerCase()) == null ) {
                        peUserNameCount.put(peCon.PEUserNameFormula__c.toLowerCase(),1);
                    }
                    else{
                        integer i = peUserNameCount.get(peCon.PEUserNameFormula__c.toLowerCase());
                        i++;
                        peUserNameCount.put(peCon.PEUserNameFormula__c.toLowerCase(),i);
                    }
                }
                for( Contact selCon : selectedContacts ) {
                    if( peUserNameCount.get(selCon.PEUserNameFormula__c.toLowerCase()) == null  ) {
                        peUserNameCount.put(selCon.PEUserNameFormula__c.toLowerCase(),1);
                        selCon.Partner_Exchange_User_Name__c =  selCon.PEUserNameFormula__c.toLowerCase(); 
                        System.debug('**LOOP COUNT1**'); 
 
                    }
                    else{                     
                      
                        integer i = peUserNameCount.get(selCon.PEUserNameFormula__c.toLowerCase());
                        i++;
                        peUserNameCount.put(selCon.PEUserNameFormula__c.toLowerCase(),i);
                        selCon.Partner_Exchange_User_Name__c =  selCon.PEUserNameFormula__c.toLowerCase() + peUserNameCount.get(selCon.PEUserNameFormula__c.toLowerCase());                       
                        System.debug('**LOOP COUNT2**'); 
 
                        boolean dupCheck = true;
                       if( peUserNameDupCheck.get(selCon.Partner_Exchange_User_Name__c) != null ) {                            
                        while (dupCheck) {                                      
                            i++;
                            peUserNameCount.put(selCon.PEUserNameFormula__c.toLowerCase(),i);
                            selCon.Partner_Exchange_User_Name__c =  selCon.PEUserNameFormula__c.toLowerCase() + peUserNameCount.get(selCon.PEUserNameFormula__c.toLowerCase());
                            System.debug('**LOOP COUNT3**'); 
 
                            if( peUserNameDupCheck.get(selCon.Partner_Exchange_User_Name__c) == null ) {
                              dupCheck = false;                              
                            }
              }
              peUserNameCount.put(selCon.PEUserNameFormula__c.toLowerCase(),i);
              selCon.Partner_Exchange_User_Name__c =  selCon.PEUserNameFormula__c.toLowerCase() + peUserNameCount.get(selCon.PEUserNameFormula__c.toLowerCase());
              System.debug('**LOOP COUNT4**'); 
           
                      }
                    }
                }   
            }
        }catch( Exception ex ) {
        ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }
    }
    
    /*
    Method name: updateNewPEUsernameOnContact
    Return Type: void
    Parameters: updatedObject
    Business Logic: This function is used to update new Partner Exchange Username in case duplicate is present in CSP
    */   
    public void updateNewPEUsernameOnContact(SObject[] oldObjects, SObject[] updatedObjects)
    {   
        List<Contact> contactOldList= oldObjects;
        List<Contact> contactNewList= updatedObjects;
        set<String> peUserName = new set<String>();
        list<Contact> selectedContacts = new list<Contact>();
        map<String, Integer> peUserNameCount = new map<String, Integer>();
        set<Id> selectedConID = new set<Id>();
        List<Contact> contactIds= new List<Contact>();
        try{
            for(integer i=0;i<ContactNewList.size();i++)
            {
                if((contactOldList[i].Generate_New_PE_Username__c != contactNewList[i].Generate_New_PE_Username__c) && contactNewList[i].Generate_New_PE_Username__c)
                {
                    peUserName.add( ContactNewList[i].PEUserNameFormula__c.toLowerCase() );
                    selectedContacts.add(ContactNewList[i]);
                    selectedConID.add(ContactNewList[i].Id);
                }
            }    

            if( selectedContacts.size() > 0 && selectedContacts != null ) {
                list<Contact> contactWithPEName = [ select Id, PEUserNameFormula__c from Contact where PEUserNameFormula__c IN :peUserName and Partner_Exchange_User_Name__c != null ];
                for( Contact peCon : contactWithPEName ) {
                    if( peUserNameCount.get(peCon.PEUserNameFormula__c.toLowerCase()) == null ) {
                        peUserNameCount.put(peCon.PEUserNameFormula__c.toLowerCase(),1);
                    }
                    else{
                        integer i = peUserNameCount.get(peCon.PEUserNameFormula__c.toLowerCase());
                        i++;
                        peUserNameCount.put(peCon.PEUserNameFormula__c.toLowerCase(),i);
                    }
                }
                for( Contact selCon : selectedContacts ) {
                    if( peUserNameCount.get(selCon.PEUserNameFormula__c.toLowerCase()) == null  ) {
                        peUserNameCount.put(selCon.PEUserNameFormula__c.toLowerCase(),1);
                        selCon.Partner_Exchange_User_Name__c = selCon.PEUserNameFormula__c.toLowerCase();   
                    }
                    else{                    
                        if(selCon.CSP_Failure_Count__c == null){
                            selCon.Partner_Exchange_User_Name__c =  selCon.PEUserNameFormula__c.toLowerCase() + peUserNameCount.get(selCon.PEUserNameFormula__c.toLowerCase());
                            integer i = peUserNameCount.get(selCon.PEUserNameFormula__c.toLowerCase());
                            selCon.CSP_Failure_Count__c = peUserNameCount.get(selCon.PEUserNameFormula__c.toLowerCase());
                            i++;
                            peUserNameCount.put(selCon.PEUserNameFormula__c.toLowerCase(),i);
                        }
                        else{
                            selCon.CSP_Failure_Count__c = selCon.CSP_Failure_Count__c + 1;
                            selCon.Partner_Exchange_User_Name__c =  selCon.PEUserNameFormula__c.toLowerCase() + selCon.CSP_Failure_Count__c;
                        }
                    }
                }   
            }
        }catch( Exception ex ) {
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }
    }
/* Name: syncInfoWithBirchOnInsert
Description:
*/   
    public void syncInfoWithBirchOnInsert(SObject[] newObjects)
    {
        try{
        Set<Id> contId = new Set<Id>();
        for(Contact c: (List<Contact>)newObjects)
        {
             if(((c.Manage_MDF__c != null && c.Manage_MDF__c == true) || (c.MDF_Read_Only__c != null && c.MDF_Read_Only__c == true)) && !c.Account.Stop_Birch__c)
            {
                contId.add(c.Id);    
            }
        }
        if(!System.isBatch() && !contId.isEmpty())
        {
            MDF_BirchUserAccountProvService upBatch = new MDF_BirchUserAccountProvService(null, contId);
            Database.executeBatch(upBatch);                
        }
    }
    catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}
 /* Name: syncInfoWithBirch
Description:
*/    
    public void syncInfoWithBirch(SObject[] oldObjects, SObject[] updatedObjects)
    {
        try{
        Set<Id> contId = new Set<Id>();
        List<Contact> contactOldList= oldObjects;
        List<Contact> contactNewList= updatedObjects;
        Contact newContact;
        Contact oldContact;
        for(Integer i=0 ; i< contactNewList.size(); i++)
        {   
            newContact = contactNewList.get(i);
            oldContact = contactOldList.get(i);
             if(!newContact.Account.Stop_Birch__c && ((newContact.Manage_MDF__c != null && newContact.Manage_MDF__c == true) || (newContact.MDF_Read_Only__c != null && newContact.MDF_Read_Only__c == true))
               && (oldContact.Manage_MDF__c != newContact.Manage_MDF__c || oldContact.MDF_Read_Only__c != newContact.MDF_Read_Only__c)
               )
            {
                contId.add(newContact.Id);    
            }
        }
        if(!System.isBatch() && !contId.isEmpty())
        {
            MDF_BirchUserAccountProvService upBatch = new MDF_BirchUserAccountProvService(null, contId);
            Database.executeBatch(upBatch);                
        }
    }
    catch(Exception e){
        ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
    }
    }
    
    /*Name:updateBillingAndServiceStatusOnContact
      Description:
    */
    public void updateBillingAndServiceStatusOnContact(SObject[] oldObjects, SObject[] updatedObjects)
    {   
        List<Contact> contactOldList= oldObjects;
        List<Contact> contactNewList= updatedObjects;
        List<Account> accList = new List<Account>();
        list<Contact> selectedContacts = new list<Contact>();
        map<ID,Account> accountmap = new map<ID,Account>();
        set<Id> selecteAccID = new set<Id>();
        List<Contact> contactIds= new List<Contact>();
        try{
            for(contact con : contactNewList){
                if(con.Manage_Billing__c == true || con.Service_Assurance__c == true){
                    selecteAccID.add(con.accountid);
                }
            }
            
            if(selecteAccID != null && selecteAccID.size() > 0){
                accList = [select Billing__c,Trouble_Tickets__c,Service_Level_Agreements__c,Network_Status__c from account where ID IN: selecteAccID];
            }
            for(account acc : accList){
                accountmap.put(acc.id,acc);
            }
            
            for(integer i=0;i<ContactNewList.size();i++)
            {
                 if((contactOldList[i].Manage_Billing__c != contactNewList[i].Manage_Billing__c) || contactOldList[i].Service_Assurance__c != contactNewList[i].Service_Assurance__c || contactOldList[i].isconverted__c != contactNewList[i].isconverted__c){ 
                    if(contactNewList[i].Manage_Billing__c){
                        if(accountmap.get(contactNewList[i].accountid) != null ){
                            if( accountmap.get(contactNewList[i].accountid).Billing__c){
                               
                                contactNewList[i].Billing_Status__c = BuyflowConstant.Requested;
                            }
                            else{
                                contactNewList[i].Billing_Status__c = BuyflowConstant.Revoked;
                            }
                        }
                        else{
                            contactNewList[i].Billing_Status__c = BuyflowConstant.Revoked;
                        }
                        
                    }
                    else{
                        contactNewList[i].Billing_Status__c = BuyflowConstant.Revoked;
                    }
                    if(contactNewList[i].Service_Assurance__c){
                        if(accountmap.get(contactNewList[i].accountid) != null){
                           
                            if( accountmap.get(contactNewList[i].accountid).Trouble_Tickets__c && accountmap.get(contactNewList[i].accountid).Service_Level_Agreements__c && accountmap.get(contactNewList[i].accountid).Network_Status__c){
                                contactNewList[i].Service_Assurance_Status__c = BuyflowConstant.Requested;
                            }
                            else{
                                contactNewList[i].Service_Assurance_Status__c = BuyflowConstant.Revoked;
                            }
                        }
                        else{
                                contactNewList[i].Service_Assurance_Status__c = BuyflowConstant.Revoked;
                            }
                    }
                    else{
                            contactNewList[i].Service_Assurance_Status__c = BuyflowConstant.Revoked;
                        }
                    
              }  
            } 
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    /*Name:CheckBillingAndServiceStatusOnCreation
      Description:
    */
    public void CheckBillingAndServiceStatusOnCreation(SObject[] newObjects) 
    {
        try
        {
            List<Contact> ContactNewList= newObjects;
            List<account> accLst = new List<account>();
            Set<Id> accountids=new Set<Id>();
            map<id,Account> accountmap = new map<id,account>();
            for(Contact con: ContactNewList)
            {   
                if(con.accountid != null)
                {
                    if(con.Manage_Billing__c == true || con.Service_Assurance__c == true){
                        accountids.add(con.accountid);
                    }
                }
            }
            if(accountids != null && accountids.size() >0 )
            {
                accLst = [select id,Billing__c,Trouble_Tickets__c,Service_Level_Agreements__c,Network_Status__c from account where Id IN: accountids];
              
            }
            if(accLst != null && accLst.size()>0)
            {
                for(account acc : accLst)
                {
                    accountmap.put(acc.id,acc);
                }
            }
            
            for(integer i=0;i<ContactNewList.size();i++)
            {
            
                if(ContactNewList[i].accountid != null){
                    if(ContactNewList[i].Manage_Billing__c == true && accountmap.get(ContactNewList[i].accountid)!=null && accountmap.get(ContactNewList[i].accountid).Billing__c==true)
                    {
                        ContactNewList[i].Billing_Status__c= BuyflowConstant.Requested;
                    }
                    else 
                    {
                        ContactNewList[i].Billing_Status__c= BuyflowConstant.Revoked;
                    }
                    
                    if(ContactNewList[i].Service_Assurance__c == true && accountmap.get(ContactNewList[i].accountid)!=null && accountmap.get(ContactNewList[i].accountid).Trouble_Tickets__c==true && accountmap.get(ContactNewList[i].accountid).Service_Level_Agreements__c==true && accountmap.get(ContactNewList[i].accountid).Network_Status__c==true)
                    {
                        ContactNewList[i].Service_Assurance_Status__c= BuyflowConstant.Requested;
                    }
                    else 
                    {
                        ContactNewList[i].Service_Assurance_Status__c= BuyflowConstant.Revoked;
                    }
                }
                else{
                    ContactNewList[i].Service_Assurance_Status__c= BuyflowConstant.Revoked;
                    ContactNewList[i].Billing_Status__c= BuyflowConstant.Revoked;
                }
            }
        }
        Catch(Exception e)
        {}
    }       
          
          
          
    
  }