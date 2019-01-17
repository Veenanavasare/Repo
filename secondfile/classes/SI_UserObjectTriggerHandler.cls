/*Name:SI_UserObjectTriggerHandler
Description:
*/
public without sharing class SI_UserObjectTriggerHandler extends SITriggerOperations.SITriggerImpl 
{
    public boolean isExecuted ;
    
    //Default cons
    /*Name:SI_UserObjectTriggerHandler
     * Description:
     */
    public SI_UserObjectTriggerHandler() 
    {
        isExecuted = true;
    }
    
    
    /* Name:onBeforeInsert
     * Description:An Overridden method
     */
    public override boolean onBeforeInsert(SObject[] newObjects) 
    {
        try 
        {
            updateFederationIdOnUser(newObjects);
            ChatterAnswerslicense(newObjects);
            populateATOMFieldsOnCommunityUserFromContact(newObjects);
        } 
        catch(Exception excep) 
        {
            isExecuted = false;
            throw excep;
        }
        return isExecuted;
    }
    
    //An Overridden method
/*Name:onAfterInsert
Description:
*/
    public override boolean onAfterInsert(SObject[] newObjects) 
    {
        try 
        {
            updateContactOnInsert(newObjects);            
            addUserToGroup(newObjects);
            addUserToPermissionSetOnInsert(newObjects);
            addApttusLicenseOnInsert(newObjects);
            addSIEBMUserToLibraryViewerGroup(newObjects);
            if(!Test.isRunningTest()){
            createAccountSharingrule(newObjects);
            }                      
        } 
        catch(Exception excep) 
        {
            isExecuted = false;
            throw excep;
        }
        return isExecuted;
    }
  
    
    //An Overridden method
    /*Name:onBeforeUpdate
Description:
*/
    public override boolean onBeforeUpdate(SObject[] oldObjects,SObject[] newObjects,Map<Id,SObject> newObjectsMap )
    {
        try
        {  
            updateFederationIdOnUser(newObjects);
            generateTempPassword(oldObjects,newObjects);
            CheckPortalAdminOnContact(oldObjects,newObjects);
        }
        catch(Exception e)
        {
            
            isExecuted=false;
            throw e;
        }
        return isExecuted;    
    }
    
    //An Overridden method
    /*Name:onAfterUpdate
Description:
*/
    public override boolean onAfterUpdate(SObject[] oldObjects,SObject[] newObjects,Map<Id,SObject> newObjectsMap)
    {
        try
        {
           updateContactOnUpdate(oldObjects,newObjects);
           addUserToPermissionSetOnUpdate(newObjects,oldObjects);
           addApttusLicenseOnUpdate(oldObjects, newObjects);
           addSIEBMUserToLibraryViewerGroup(newObjects);
        }
        catch(Exception e)
        {
          
            isExecuted=false;
            throw e;
        }
        return isExecuted;    
    }
    /*Name:updateFederationIdOnUser
Description:
*/    
    public void updateFederationIdOnUser(SObject[] newObjects)
    {
        try{
       List<User> userList=newObjects;
       Set<Id> contactIds =new Set<Id>();
       map<Id,String> conMap =new map<Id,String>();
       list<Contact> conList =new list<Contact>();
       map<Id,Boolean> testCompanyMap =  new map<Id,Boolean>();
       
       for(User u:UserList)
       {
            if(u.ProfileId == label.Community_User_Id)
            {
                  ContactIds.add( u.ContactId );
            }
       }
       
       ConList=[Select ID, PE_User_ID__c, Test_Company__c from Contact where Id IN : ContactIds];
      
       for(Contact C:ConList)
       {
            ConMap.put(C.ID,C.PE_User_ID__c);
            testCompanyMap.put( C.ID, C.Test_Company__c );
       }
      
       for(User u:UserList)
       {
            if(u.ProfileId == label.Community_User_Id)
            {
                if(ConMap != null && ConMap.get(u.ContactId) != null)
                {
                    if(userinfo.getProfileId() == label.System_Admin_Id && u.FederationIdentifier == null)
                    {
                          u.FederationIdentifier = ConMap.get(u.ContactId);
                    }
                }
                else
                {
                    if(u.FederationIdentifier==null)
                    {
                        u.addError('The User cannot be created due to missing Federation ID');
                    }
                }

                if( ( testCompanyMap.get(u.ContactId)!=null && testCompanyMap.get(u.ContactId) && userinfo.getProfileId()!=label.System_Admin_Id && userinfo.getProfileId()!=label.EBM_Admin_Id) || (u.isActive == False && testCompanyMap.get(u.ContactId)!= null && testCompanyMap.get(u.ContactId) && userinfo.getProfileId()!=label.System_Admin_Id && userinfo.getProfileId()!=label.EBM_Admin_Id) )
                {
                    u.addError('The User cannot be created or reactivated since it is associated to an Account with Test Company = True'); 
                }
            }
        }
    }
    catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}
    /*Name:updateContactOnInsert
Description:
*/    
    public void updateContactOnInsert(SObject[] objects)
    {
        try{
          List<User> userList=objects;
          
          Set<Id> contactIds =new Set<Id>();
          Map<Id,Contact> conMap =new Map<Id,Contact>();
          List<Contact> conList =new List<Contact>();
          List<Contact> contactUpdate =new List<Contact>();
          
          for(integer i=0;i<UserList.size();i++)
          {
                if(UserList[i].UserType==SIConstants.User_Type_Customer && UserList[i].FederationIdentifier!=null)
                {
                        ContactIds.add(UserList[i].ContactId);
                }
          }
          
          ConList=[Select ID,PE_User_ID__c from Contact where Id IN:ContactIds];
          
          for(Contact C:ConList)
          {
                ConMap.put(C.ID,C);
          }
          
          for(User u:UserList)
          {
              if(u.UserType==SIConstants.User_Type_Customer && u.FederationIdentifier!=null)
              {
                    Contact contact_to_update = ConMap.get(u.ContactId);
                    if(contact_to_update!=null && contact_to_update.PE_User_ID__c==null) 
                    {
                        if(userinfo.getProfileId()==label.System_Admin_Id)
                        {
                            contact_to_update.PE_User_ID__c=u.FederationIdentifier;
                            contactUpdate.add(contact_to_update);
                        }
                    }
               }
          }
           
          if(contactUpdate!=null && !contactUpdate.isEmpty())
          { 
                database.update(contactUpdate);
          }
    }
    catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}
    /*Name:updateContactOnUpdate
Description:
*/    
    public void updateContactOnUpdate(SObject[] oldObjects,SObject[] newObjects)
    {
        try{
        List<User> userNewList=newObjects;
        List<User> userOldList=oldObjects;
        
        Set<Id> contactIds =new Set<Id>();
        Set<Id> partnerContactIds =new Set<Id>();
        Set<Id> retriggerPartnerContactIds =new Set<Id>();
        
        Map<Id,Contact> conMap =new Map<Id,Contact>();
        Map<Id,Contact> partnerConMap =new Map<Id,Contact>();
        Map<Id,Contact> retriggerPartnerConMap =new Map<Id,Contact>();
        
        List<Contact> conList =new List<Contact>();
        List<Contact> partnerConList =new List<Contact>();
        List<Contact> retriggerPartnerConList =new List<Contact>();
        
        List<Contact> contactUpdate =new List<Contact>();
        List<Contact> partnerContactUpdate =new List<Contact>();
        List<Contact> retriggerPartnerContactUpdate =new List<Contact>();
        
        for(integer i=0; i<UserNewList.size(); i++)
        {
            if(UserNewList[i].UserType==SIConstants.User_Type_Customer &&((UserOldList[i].FederationIdentifier!=UserNewList[i].FederationIdentifier) && UserNewList[i].FederationIdentifier!=null))
            {
                ContactIds.add(UserNewList[i].ContactId);
            }
        }
        
        for(integer i=0; i<UserNewList.size(); i++)
        {
            if(UserNewList[i].UserType==SIConstants.User_Type_Partner && (UserOldList[i].FirstName !=UserNewList[i].FirstName || UserOldList[i].LastName !=UserNewList[i].LastName || UserOldList[i].Phone !=UserNewList[i].Phone || UserOldList[i].Email !=UserNewList[i].Email))
            {
                partnerContactIds.add(UserNewList[i].ContactId);
            }
        }
        
        for(integer i=0; i<UserNewList.size(); i++)
        {
            if(UserNewList[i].UserType==SIConstants.User_Type_Partner && ( UserOldList[i].CSP_User_Provisioning_Status__c !=UserNewList[i].CSP_User_Provisioning_Status__c ) && UserNewList[i].CSP_User_Provisioning_Status__c == UtilityConstant.USERRESERVE_FAILED)
            {
                retriggerPartnerContactIds.add(UserNewList[i].ContactId);
            }
        }
        
        if( ContactIds.size() > 0 ){        
            ConList = [Select ID,PE_User_ID__c,Email from Contact where Id IN: ContactIds];
            for(Contact C: ConList)
            {
                ConMap.put(C.ID,C);
            }
            for(Integer i=0;i<UserNewList.size();i++)
            {
              if(UserNewList[i].UserType==SIConstants.User_Type_Customer && (UserOldList[i].FederationIdentifier!=UserNewList[i].FederationIdentifier) && UserNewList[i].FederationIdentifier!=null)
              {
                    Contact contact_to_update = ConMap.get(UserNewList[i].ContactId);
                    if(contact_to_update!=null) 
                    {
                        if(userinfo.getProfileId()==label.System_Admin_Id)
                        {
                            contact_to_update.PE_User_ID__c=UserNewList[i].FederationIdentifier;
                            contactUpdate.add(contact_to_update);
                        }    
                    }
               }
            }
            if(contactUpdate!=null && !contactUpdate.isEmpty())
            { 
                database.update(contactUpdate);
            }
        }
        
        if( partnerContactIds.size() > 0 ) {
            partnerConList = [Select ID,PE_User_ID__c,Email from Contact where Id IN: partnerContactIds];
            for(Contact C: partnerConList)
            {
                partnerConMap.put(C.ID,C);
            }
            for(Integer i=0;i<UserNewList.size();i++)
            {
                if(UserNewList[i].UserType==SIConstants.User_Type_Partner && (UserOldList[i].FirstName != UserNewList[i].FirstName || UserOldList[i].LastName != UserNewList[i].LastName || UserOldList[i].Phone != UserNewList[i].Phone || UserOldList[i].Email != UserNewList[i].Email))
                { 
                    Contact partner_contact_to_update = partnerConMap.get(UserNewList[i].ContactId);
                    if(partner_contact_to_update !=null) 
                    {
                        partner_contact_to_update.FirstName = UserNewList[i].FirstName;
                        partner_contact_to_update.LastName = UserNewList[i].LastName;
                        partner_contact_to_update.Phone = UserNewList[i].Phone;
                        partner_contact_to_update.Email = UserNewList[i].Email;
                        partnerContactUpdate.add(partner_contact_to_update);
                    }
                }
            }
            if(partnerContactUpdate!=null && !partnerContactUpdate.isEmpty())
            { 
                database.update(partnerContactUpdate);
            }
        }
        
        if( retriggerPartnerContactIds.size() > 0 ) {
            retriggerPartnerConList = [Select ID,PE_User_ID__c,Email from Contact where Id IN: retriggerPartnerContactIds];
            for( Contact C: retriggerPartnerConList )
            {
                retriggerPartnerConMap.put(C.ID,C);
            }
            for(Integer i=0;i<UserNewList.size();i++)
            {
                if(UserNewList[i].UserType==SIConstants.User_Type_Partner && UserNewList[i].CSP_User_Provisioning_Status__c == UtilityConstant.USERRESERVE_FAILED)
                { 
                    Contact cont = retriggerPartnerConMap.get(UserNewList[i].ContactId);
                    if( cont!=null ) 
                    {
                        cont.Generate_New_PE_Username__c = True;
                        retriggerPartnerContactUpdate.add(cont);
                    }
                }
            }
            if(retriggerPartnerContactUpdate!=null && !retriggerPartnerContactUpdate.isEmpty())
            { 
                database.update(retriggerPartnerContactUpdate);
            }
        }
    }
    catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}
    /*Name:ChatterAnswerslicense
Description:
*/    
    public static void chatterAnswerslicense(SObject[] newObjects)
    { 
try{    
        List<User> userNewList=newObjects;
        for(User u:UserNewList)
        {  
            if( u.profileId == label.Community_User_Id && u.UserPermissionsChatterAnswersUser == false )
            {
               // u.UserPermissionsChatterAnswersUser = true;
            }
        }
    }
    catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}
    /*Name:addUserToGroup
Description:
*/     
    public static void addUserToGroup(SObject[] newObjects)
    { 
try{    
        list<User> userList = newObjects;
        Set<Id> userIds =new Set<Id>();
        if(userList.size() > 0)
        {
            for(User u: userList) 
            {
                if(u.UserType != SIConstants.User_Type_Partner)
                {
                    userIds.add(u.Id);
                    AddToGroups.addToPublicGroup(userIds);
                }
            }
        }
    }
    catch(Exception e){
        ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
    }
}
    /*Name:addSIEBMUserToLibraryViewerGroup
    Description:
    */     
    public static void addSIEBMUserToLibraryViewerGroup(SObject[] newObjects){ 
        try{    
            list<User> userList = newObjects;
            Set<Id> userIds =new Set<Id>();
            if(userList.size() > 0)
            {
                for(User u: userList) 
                {
                     userIds.add(u.Id);                     
                }
                AddToGroups.addSIEBMUserToLibraryViewerGroup(userIds);
            }
        }
        catch(Exception e){
    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
    }
}
/*Name:addUserToPermissionSetOnInsert
Description:
*/    
    public static void addUserToPermissionSetOnInsert(SObject[] newObjects)
    { 
try{    
        list<User> userList = newObjects;
        Set<Id> userIds =new Set<Id>();
            
        if( userList.size() > 0 )
        {
            for( User u: userList ) 
            {
                if(u.UserType == SIConstants.User_Type_Partner)
                {
                    userIds.add(u.Id);
                    PermissionSets.addUserToPermissionSets(userIds);
                }
            }
        }
    }
    catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}
        /*Name:addUserToPermissionSetOnUpdate
Description:
*/    
    public static void addUserToPermissionSetOnUpdate(SObject[] newObjects, SObject[] oldObjects)
    { 
try{    
        List<User> userNewList = newObjects;
        List<User> userOldList = oldObjects;
        
        Set<Id> userIds =new Set<Id>();
        
        for(Integer i=0; i<UserNewList.size(); i++)
        {
            if(UserNewList[i].UserType == SIConstants.User_Type_Partner && (UserOldList[i].Create_Modify_Profile__c != UserNewList[i].Create_Modify_Profile__c || UserOldList[i].Begin_Quote__c != UserNewList[i].Begin_Quote__c || UserOldList[i].Approve_Contracts__c != UserNewList[i].Approve_Contracts__c || UserOldList[i].Provider_Directory__c != UserNewList[i].Provider_Directory__c ))
            { 
                userIds.add(UserNewList[i].Id);
                PermissionSets.addUserToPermissionSets(userIds);
            }
        }
    }
    catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}
        /*Name:populateATOMFieldsOnCommunityUserFromContact
Description:
*/        
    public void populateATOMFieldsOnCommunityUserFromContact(SObject[] objects)
    {
        try{
        list<User> newList= objects;
        set<Id> contactIds = new set<Id>();
        
        for( User u : NewList )
        {
            contactIds.add( u.ContactId );
        }
            
        list<Contact> contactList = [ SELECT Id, Partner_User_Role__c, Create_Modify_Profile__c, Begin_Quote__c, Approve_Contracts__c, Manage_MDF__c, MDF_Read_Only__c, Service_Assurance__c, Manage_Billing__c, Provider_Directory__c FROM Contact WHERE contact.Id IN : contactIds ];
        
        for( User u : newList )
        {
            for( Contact con : contactList )
            {
                if( u.ContactId == con.Id ) 
                {
                    if( con.Create_Modify_Profile__c != null && con.Begin_Quote__c!=null && con.Approve_Contracts__c != null && con.Manage_MDF__c != null && con.MDF_Read_Only__c != null && con.Provider_Directory__c != null)
                    {
                        u.Create_Modify_Profile__c = con.Create_Modify_Profile__c;
                        u.Begin_Quote__c = con.Begin_Quote__c;
                        u.Approve_Contracts__c = con.Approve_Contracts__c;
                        u.Manage_MDF__c = con.Manage_MDF__c;
                        u.MDF_Read_Only__c = con.MDF_Read_Only__c;
                        //u.Service_Assurance__c = con.Service_Assurance__c;
                        //u.Manage_Billing__c = con.Manage_Billing__c;
                        u.Provider_Directory__c = con.Provider_Directory__c;
                    } 
                }
            }
        }
    }
    catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}
    
    /*  Methods for Password Generation for Partner Users 
        Description: Generates a 6 digit Password - Format = 2 UpperCase + 3 LowerCase + 3 Special Character + 2 Numeric  
    */
  
    // Strings for Password format 
    Public List<String> upperCaseCharacters=SIConstants.UPPERCASECHARACTERS;
    Public List<String> numbericCase=SIConstants.NUMBERIC;
    Public List<String> lowerCaseCharacter=SIConstants.LOWERCASECHARACTERS; 
    Public List<String> specialCaseCharacter=SIConstants.SPECIAL;
    Public String txtdata=SpecialCharacterConstant.CONCAT;
    Public String txtLower=SpecialCharacterConstant.CONCAT;
    Public String txtNumeric=SpecialCharacterConstant.CONCAT;
    Public String txtSpecial=SpecialCharacterConstant.CONCAT;
    
    // Methods for generating Password combination
    
    //Logic starts here for Password Generation
    
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
       for(integer i=0;i<3;i++)
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
       for(integer i=0;i<3;i++)
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
    
    // Logic Ends Here for Password Generation
    
    /*
        Method Name: generateTempPassword
        Description: Method to Set the Temporary Password when a Partner User is Activated 
                     Invoked before update - after setting isActive = True for an Inactive Partner User
    */    
    public void generateTempPassword(SObject[] oldObjects,SObject[] newObjects)
    {
        try{
        List<User> userNewList=newObjects;
        List<User> userOldList=oldObjects;
     
        for(integer i=0;i<UserNewList.size();i++)
        {
            if(UserNewList[i].UserType==SIConstants.User_Type_Partner && ((UserOldList[i].isActive != UserNewList[i].isActive ) && UserNewList[i].isActive == True))
            {
                String password=getUpperChar()+getSpecialChar()+getNumericChar()+getLowerChar();
                UserNewList[i].Temppassword__c=Password;
            }
        }
    }
    catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}

/* Method to provide Apttus license to user if newly created User has Begin Quote or Approve Contracts permission */ 
   
/* 
 Name: addApttusLicenseOnInsert
 Description: 
 */ 
    public static void addApttusLicenseOnInsert(SObject[] newObjects){ 
try{    
        List<User> userList = newObjects;
        Set<String> userIds = new Set<String>();
        Integer addLicense = 5;
            
        for(User u: userList){
            if(u.UserType == SIConstants.User_Type_Partner){
                if(u.Begin_Quote__c == true || u.Approve_Contracts__c == true){     //newly created user has one of the 2 permissions
                    addLicense = 1;
                    userIds.add(u.Id);
                    licenseAssignment.addUserToLicense(addLicense,userIds);
                }
            }
        }
    }
    catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}
    
/* Method to provide or revoke Apttus license from user if updated User has change in Begin Quote or Approve Contracts permission */ 

/* 
 Name: addApttusLicenseOnUpdate
 Description: 
 */ 
    public static void addApttusLicenseOnUpdate(SObject[] oldObjects, SObject[] newObjects){
try{        
        List<User> oldUserList = oldObjects;
        List<User> userList = newObjects;
        Set<String> userIds = new Set<String>();
        Integer addLicense = 5;
        
        for(User uOld: oldUserList){
            for(User u: userList){
                if(u.UserType == SIConstants.User_Type_Partner && (uOld.Begin_Quote__c != u.Begin_Quote__c || uOld.Approve_Contracts__c != u.Approve_Contracts__c ) && uOld.Id == u.Id){
                    if(u.Begin_Quote__c == true || u.Approve_Contracts__c == true){         //updated user has one of the 2 permissions
                        addLicense = 1;
                        userIds.add(u.Id);
                        licenseAssignment.addUserToLicense(addLicense,userIds);
                    } else if(u.Begin_Quote__c == false && u.Approve_Contracts__c == false){    //updated user has neither of the 2 permissions
                        addLicense = 0;
                        userIds.add(u.Id);
                        licenseAssignment.addUserToLicense(addLicense,userIds);
                    } 
                }
            }
        }
    }
    catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}
    
    /* Method to provide Account Sharing rules */ 
   
/* 
 Name: createAccountSharingrule
 Description: 
 */ 
    public static void createAccountSharingrule(SObject[] newObjects){
try{        
        List<User> userList =  newObjects;
        Set<Id> contactIds =new Set<Id>();  
     //   Set<Id> accountIds =new Set<Id>(); 
        Map<Id,Id> parentAccountMap = new Map<Id,Id>();
        List<Contact> conList = new List<Contact>();     
            
        for(User u: userList){
            if(u.IsPrmSuperUser || u.UserType == SIConstants.User_Type_Partner){                   
                ContactIds.add( u.ContactId );
            }
        }
        
        
        if(ContactIds.size() > 0) {
          ConList=[Select AccountID from Contact where Id IN : ContactIds];
          for(Contact c: ConList){                            
         //     accountIds.add( c.AccountID );  
              parentAccountMap.put(c.AccountID,c.AccountID);         
          }
          
        }        
        if(!Test.isRunningTest()){
        if(parentAccountMap.size() > 0) {
        //  String shareObjectName = UtilityConstant.ACCOUNTSHARE;
        //  SIHelper.accountSharingPartnerRule(accountIds,shareObjectName);
          SIHelper.createSPSharingPartnerRule(SIConstants.ACCOUNT_SHARE,parentAccountMap);
        }
        }
        
    }
    catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}
public void CheckPortalAdminOnContact(SObject[] oldObjects,SObject[] newObjects)
    {
        try{
        List<User> userNewList=newObjects;
        List<User> userOldList=oldObjects;
        Set<Id> contactIds =new Set<Id>();
        Set<Id> accountIds =new Set<Id>();
        Map<ID,Boolean> accPortalAdminMap = new Map<ID,Boolean>();
        integer portalAdminCount;
        for(integer i=0;i<UserNewList.size();i++)
        {
            if(UserNewList[i].UserType==SIConstants.User_Type_Partner && ((UserOldList[i].isActive != UserNewList[i].isActive ) && UserNewList[i].isActive == false))
            {
                for(User u:UserNewList)
                {
                    if(u.ProfileId == label.Partner_UserID)
                    {
                        
                        if(u.accountId != null){
                            accountIds.add( u.accountId );
                        }
                    }
                }
             }
          }      
          List<User> usrLst = new List<User>();
          usrLst = [Select IsActive,Community_Role__c, AccountId From User where accountId IN: accountIds];
          //List<Contact> conlist = [Select Primary_Contact__c,Partner_Exchange_Status__c, AccountId From Contact where accountId IN: accountIds];
          for(integer i=0;i<UserNewList.size();i++)
            {
                for( Id accId : accountIds )
                {
                    portalAdminCount = 0;
                    for( User con : usrLst )
                    {
                        if( accId == con.accountId )
                        {
                            if(con.IsActive && con.Community_Role__c == 'Admin'){
                                portalAdminCount ++;
                            }
                        }
                    }
                    System.debug('portalAdminCount ----->'+portalAdminCount );
                    if((portalAdminCount == 1 || portalAdminCount == 2) && UserNewList[i].Community_Role__c == 'Admin' ){
                        accPortalAdminMap.put(accId,true);
                    }
                    else{
                       accPortalAdminMap.put(accId,false); 
                    }
                } 
                
                for(integer j=0;i<usrLst.size();j++){
                    if( accPortalAdminMap.get(usrLst[j].accountId) == true  )
                    {
                        
                        UserNewList[i].addError('Update not allowed!!! There should be atleast two Portal Administrator for an SP Account!!!');
                        System.debug('inside error');
                        break;
                    }
                }
            
        }
    }
    catch(Exception e){
        
    }
}
}