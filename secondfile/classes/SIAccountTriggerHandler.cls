public with sharing class SIAccountTriggerHandler extends SITriggerOperations.SITriggerImpl{
    public boolean isExecuted ;
    
    //Default cons
    public SIAccountTriggerHandler() {
        isExecuted = true; 
    }
    
    public override boolean onBeforeUpdate(SObject[] oldObjects, SObject[] updatedObjects, Map<Id, SObject>  newObjectsMap )  {
        try {
            
            String obj='Account';
            String event='update';
            SIWFEngineUtility.getInstance().Rulescoringengine(obj,event,oldObjects,updatedObjects);
            accountBillingInformation(updatedObjects);
            changeUserStatusRelatedToAccount(oldObjects,updatedObjects);
            if(!Test.isRunningTest()){
            validateAIAMPSDate(oldObjects,updatedObjects);  // AIA MPS Signing Date Validation.
            }
        } catch(Exception excep) {
            System.debug('Exception Caught :'+excep.getMessage());
            isExecuted = false;
            throw excep;
        }
        return isExecuted;
    }
    
    public override boolean onAfterUpdate(SObject[] oldObjects,SObject[] newObjects,Map<Id,SObject> newObjectsMap ){
        try{
            system.debug('look for me: calling Birch provisioning');
            // PROD DEFECT FIX : 190373
            list<Account> newAccountList = new list<account>() ;// = newObjectsMap;
             //syncInfoWithBirch(newObjects);
            for(Account AcOld :(List<account>)oldObjects){
                Account newAccObj = (Account)newObjectsMap.get(AcOld.id);                 
                if(newAccObj.Lead_Id__c != null){
                    if(AcOld.BillingStreet != newAccObj.BillingStreet || AcOld.BillingCity != newAccObj.BillingCity  || AcOld.BillingPostalCode != newAccObj.BillingPostalCode || AcOld.BillingState != newAccObj.BillingState || AcOld.Name != newAccObj.Name || AcOld.Current_Tier__c != newAccObj.Current_Tier__c){
                        //system.debug('\n -- Now the birch eligible account');
                        newAccountList.add(newAccObj);
                    }
                }               
            }
            executeAutoProductEnabling(oldObjects,newObjects);
            createUpdateAccountOnNetExam(oldObjects,newObjects,true);
            updateContactMdf(oldObjects,newObjects,true);
           // changeUserStatusRelatedToAccount(oldObjects,newObjects);
           //BD account creation call
            sendAcctUsertoBD(null,oldObjects,newObjectsMap,true);
            createAccShareonUpdate(oldObjects,newObjectsMap);
            ChangeBillingAndServiceStatusOnContactAfterUpdate(newObjects,oldObjects);
            updateAccountForASE(oldObjects,newObjects);
            // PROD DEFECT FIX : 190373
            if(!newAccountList.isEmpty() && !SIRecursiveCheck.recursiveAccountTriggerHandler_BirchAccountUpdate ){                
                syncInfoWithBirch((list<SObject>)newAccountList);       
                system.debug('\n \n \n ATTConstants.recursiveAccountTriggerHandler_BirchAccountUpdate 2 \n \n '+ SIRecursiveCheck.recursiveAccountTriggerHandler_BirchAccountUpdate + '\n \n \n \n \n ' );
            }
            SIRecursiveCheck.recursiveAccountTriggerHandler_BirchAccountUpdate = true;
           
        }
        catch(Exception e){
            system.Debug('Exception here:'+e.getMessage());
            isExecuted=false;
            throw e;
        }
        return isExecuted;
    }
    
     public override boolean onBeforeInsert(SObject[] updatedObjects)  {
        try {
            String obj='Account';
            String event='insert';
            SIWFEngineUtility.getInstance().Rulescoringengine(obj,event,updatedObjects,updatedObjects);
            accountBillingInformation(updatedObjects);
            if(!Test.isRunningTest()){
            validateAIAMPSDate(null,updatedObjects); //AIA MPS Signing Date validation
            }
            checkLeadConversionFlagsTrue(updatedObjects);
            
        } catch(Exception excep) {
            System.debug('Exception Caught :'+excep.getMessage());
            isExecuted = false;
            throw excep;
        }
        return isExecuted;
    }
    
    public override boolean onAfterInsert(SObject[] newObjects) {
        try {
            List<Account> acctList = newObjects;
             Map<Id,Id> parentAccountMap = new Map<Id,Id>();
             for(Account acc:acctList){
                parentAccountMap.put(acc.Id,acc.Id);                    
             }
             if(parentAccountMap.size() > 0) {        
                 SIHelper.createSPSharingPartnerRule(SIConstants.ACCOUNT_SHARE,parentAccountMap);
             }
            //Send information to Birch
            syncInfoWithBirch(newObjects);
            
            createUpdateAccountOnNetExam(newObjects,newObjects,false);
            //BD account creation call
            sendAcctUsertoBD(newObjects,null,null,false);
        
            ChangeBillingAndServiceStatusOnContact(newObjects,newObjects);
            } catch(Exception excep) {
            System.debug('Exception Caught :'+excep.getMessage());
            isExecuted = false;
            throw excep;
        }
        return isExecuted;
    }
    
    //BD User Story for account creation on after insert
    public void sendAcctUsertoBD(SObject[] insertObjects,SObject[] oldObjects,Map<Id,SObject> newObjectsMap,Boolean onUpdate){
    list<Account> accList = new list<Account>();
    Map<Id,Account> newAccMap = new Map<Id,Account>();
    if(onUpdate == FALSE){
        accList = insertObjects;
    }
    else{
        accList = oldObjects;
        for(sObject sObj:newObjectsMap.values()){
            Account accnt = (Account)sObj;
            newAccMap.put(accnt.Id,accnt);
        }
        //newAccMap = newObjectsMap;
    }
    Set<id> Acctset = new Set<id>();
    for(Account acc:accList){
        if(onUpdate == FALSE && acc.ATOM_Account__c == TRUE){
            Acctset.add(acc.id);
        }
        else if(onUpdate == TRUE && acc.ATOM_Account__c != newAccMap.get(acc.Id).ATOM_Account__c && newAccMap.get(acc.Id).ATOM_Account__c == TRUE){
            Acctset.add(acc.id);
        }
    }
    try{
    if(Acctset.size()>0){
        BDAccountUserCreationWebServAPIHelper.sendAccountDetailstoBD(Acctset);
        }
        }
     catch(Exception e){
         System.debug('Exception here :'+e);
     }
    }
    
    public void accountBillingInformation(SObject[] updatedObjects)
    {
        list<Account> accList = updatedObjects;
        
        for(Account account : accList)
        {
            if(account.Billing_Same_as_Company_Address__c)
            {
                account.Billing_Address__c=account.BillingStreet;
                account.Billing_City__c=account.BillingCity;
                account.Billing_Zip_Code__c=account.BillingPostalCode;
                account.Billing_State__c=account.BillingState;
                account.Billing_Same_as_Company_Address__c=false;
            }
        }
    }
    
    //This function willupdate all the accounts that have changed the Product Enablement Override flag to false
    public void executeAutoProductEnabling(SObject[] oldObjects, SObject[] newObjects)
    {
        list <Account> oldAccount = oldObjects;
        list <Account> updatedAccount = newObjects;
        String[] productLabels = new list <String>();
        map <Id,String[]> accountProdMap= new map <Id,String[]>();
        productLabels = getPartnerCourseProducts();
        for(Integer i=0;i<updatedAccount.size();i++)
        {
            if(oldAccount[i].Product_Enablement_Override__c != updatedAccount[i].Product_Enablement_Override__c && !updatedAccount[i].Product_Enablement_Override__c)
            {
                if((accountProdMap.isEmpty() || accountProdMap== null)|| !accountProdMap.containsKey(updatedAccount[i].Id))
                {
                    accountProdMap.put(updatedAccount[i].Id,productLabels);
                }
            }
        }
        if(!accountProdMap.isEmpty() && accountProdMap != null)
        {
            SIHelper.productEnablementAccountLevel(accountProdMap);
        }
    }
    
    //This function will return the picklist values available in Product field of Partner Course object.
    public String[] getPartnerCourseProducts()
    {
        list<Product_Administration__c> productAdminList = new  list<Product_Administration__c>();       
        String[] productLabels = new list <String>();
        try
        {
            productAdminList=[SELECT Id,NetExam_Name__c FROM Product_Administration__c];
            if(!productAdminList.isEmpty() && productAdminList != null)
            {
                for(Product_Administration__c pa : productAdminList)
                {
                    if(pa.NetExam_Name__c!= null)
                    {
                        productLabels.add(pa.NetExam_Name__c);
                    }
                }
            }   
            return productLabels;
        }
        catch(Exception e)
        {
            System.debug('Exception here :'+e);
            return null;
        }
    }
   
    //This is to find the valid Accounts to be moved to NetExam
    public void createUpdateAccountOnNetExam(SObject[] oldObjects, SObject[] newObjects, Boolean isUpdate)
    {        
        list <Account> oldAccountsList = oldObjects;
        list <Account> updatedAccountsList = newObjects;
        list <Account> listToNetExam = new list <Account>();       
            if(!isUpdate)
            {
                for(Account act:updatedAccountsList)
                {
                    if( act.Partner_Type__c != 'Wholesale' && act.Partner_Type__c != 'Enablement Resource' && act.Partner_Type__c != null )
                    {
                        listToNetExam.add(act);
                    }
                }
            }
            else
            {
                for(Integer i = 0 ; i< updatedAccountsList.size(); i++)
                {
                    if(updatedAccountsList[i].BID_ID__c != null && oldAccountsList[i].BID_ID__c == null &&  updatedAccountsList[i].Partner_Type__c != 'Wholesale' && updatedAccountsList[i].Partner_Type__c != 'Enablement Resource' && updatedAccountsList[i].Partner_Type__c != null )
                    {
                        listToNetExam.add(updatedAccountsList[i]);
                    }
                }
            }
            if(!listToNetExam.isEmpty() && listToNetExam != null && listToNetExam.size()<=10 && ((10 - Limits.getFutureCalls()) >= listToNetExam.size()) && !test.isRunningTest())
            {
                processAccountOnNetExam(listToNetExam);
            }
    } 
    
    //This is to send/update Account to NetExam
    public void processAccountOnNetExam (list <Account> accountList)
    {
        String country = SpecialCharacterConstant.CONCAT;
        for(Account act:accountList)
        {
            try{ 
                country = act.BillingCountry; 
            } 
            catch(Exception e){ 
                // No real problem here, we must not have permissions to the billing fields
            } 
            
            if(country == SpecialCharacterConstant.CONCAT) { 
                try{ 
                    country = act.ShippingCountry; 
                } 
                catch(Exception e){ 
                    // No real problem here, we must not have permissions to the shipping fields 
                } 
            } 
            
            if(country == SpecialCharacterConstant.CONCAT) { 
                country = UtilityConstant.USA; 
            }            
            if((10 - Limits.getFutureCalls()) > 0)
            {
                NetExamWebServiceAPIHelper82.SendAccountFromTrigger(act.Name,(String)act.Id, country);
            }
            else
            {
               break;
            }
        }
    }         
    
   public void changeUserStatusRelatedToAccount(SObject[] oldObjects, SObject[] updatedObjects){
        list<Account> oldAccount = oldObjects;
        list<Account> updatedAccount = updatedObjects;
        set<Id> accountIdsDeactivated = new set<Id>();
        set<Id> accountIdsActivated = new set<Id>();
        list<User> listOfUsersToDeactivate = new list<User>();
        list<User> listOfUsersToActivate = new list<User>();
        
        for( Integer i=0; i<updatedAccount.size(); i++){
            if( (oldAccount[i].Account_Status__c != updatedAccount[i].Account_Status__c) && updatedAccount[i].Account_Status__c == 'Inactive'){
                accountIdsDeactivated.add(updatedAccount[i].Id);                            
            }
            if( (oldAccount[i].Account_Status__c != updatedAccount[i].Account_Status__c) && updatedAccount[i].Account_Status__c == 'Active'){
                accountIdsActivated.add(updatedAccount[i].Id);
            }
        }
        if(accountIdsDeactivated.size() > 0){
            ChangeUserStatus.updateUserStatus(accountIdsDeactivated,True);   
        }
        if(accountIdsActivated.size() > 0){
            ChangeUserStatus.updateUserStatus(accountIdsActivated,False);   
        }
    }
     public void syncInfoWithBirch(SObject[] updatedObjects){
        Set<Id> acctId = new Set<Id>();
        for(Account c: (List<Account>)updatedObjects){
            if(c.BillingStreet != null && c.BillingState != '' && !c.Stop_Birch__c){
                acctId.add(c.Id);    
            }            
        }
        if(!System.isBatch() && !acctId.isEmpty()){
            MDF_BirchUserAccountProvService upBatch = new MDF_BirchUserAccountProvService(acctId, null);
            Database.executeBatch(upBatch);                
        }
    }
    
    /*
    * Method Name : validateAIAMPSDate()
    * Return type : void
    * Logic : Validation to ensure that AIA MPS Signing date is always greater than the signing date on Admin Control on every update / insert of account
    */
    public void validateAIAMPSDate(SObject[] oldObjects,SObject[] newObjects){

        list <Account> updatedAccount = newObjects; 
        list<Admin_Control__c> adminControlList = [Select id, AIA_MPS_Signing_Date__c from Admin_Control__c LIMIT 1];        
        string MPSDate = string.valueOf(adminControlList[0].AIA_MPS_Signing_Date__c).trim().substringBefore(' ');
        // In case of an update 
        if (oldObjects != null) { 
           list <Account> oldAccount = oldObjects;      
           for(Integer i=0;i<updatedAccount.size();i++){
               if(oldAccount[i].AIA_MPS_Signing_Date__c != updatedAccount[i].AIA_MPS_Signing_Date__c && oldAccount[i].AIA_MPS_Signing_Date__c != null && updatedAccount[i].AIA_MPS_Signing_Date__c != null){
                   if(updatedAccount[i].AIA_MPS_Signing_Date__c < adminControlList[i].AIA_MPS_Signing_Date__c){
                       updatedAccount[i].addError('Master Pricing Schedule SP signing date can not be prior to updated MPS contract available date : ' + MPSDate);
                   }
               }
           }
        } 
        // In case of an insert
        else {
            for(Integer i=0;i<updatedAccount.size();i++){
               if(updatedAccount[i].AIA_MPS_Signing_Date__c != null){
                   if(updatedAccount[i].AIA_MPS_Signing_Date__c < adminControlList[i].AIA_MPS_Signing_Date__c){
                       updatedAccount[i].addError('Master Pricing Schedule SP signing date can not be prior to updated MPS contract available date : ' + MPSDate);
                   }
               }
           }
        }    
         
    }
    //Update related Contacts
    public void updateContactMdf(SObject[] oldObjects,SObject[] newObjects,Boolean onUpdate){
        list <Account> oldAccount = oldObjects;
        list <Account> updatedAccount = newObjects;
        set<Id>setAccountId = new set<Id>();
          set<Id> accountIdSet = new set<Id>();
        for(Integer i=0;i< updatedAccount.size();i++){
            if(oldAccount[i].BasicTier__c != updatedAccount[i].BasicTier__c && updatedAccount[i].BasicTier__c ){
                setAccountId.add(updatedAccount[i].Id);}
                if(oldAccount[i].BasicTier__c != updatedAccount[i].BasicTier__c && !updatedAccount[i].BasicTier__c){
                accountIdSet.add(updatedAccount[i].Id);
                }
        }
        if(!setAccountId.isEmpty()){
            list<Contact>lstCon = [select id,Manage_MDF__c,MDF_Read_Only__c,accountId from contact where accountId IN : setAccountId];
            if(!lstCon.isEmpty()){
                for(contact con : lstCon){
                    con.Manage_MDF__c = false;
                    con.MDF_Read_Only__c = false;
                }
                update lstCon;
            }
        }
        if(!accountIdSet.isEmpty()){
            list<Contact> ConList = [select id,Manage_MDF__c,Primary_Contact__c,MDF_Read_Only__c,accountId from contact where accountId IN : accountIdSet];
            if(!ConList.isEmpty()){
                for(contact con : ConList){
                        if(con.Primary_Contact__c)
                    con.Manage_MDF__c = true;
                   
                }
                update ConList;
            }
        }
    }
    public void createAccShareonUpdate(SObject[] oldObjects,Map<Id,SObject> newObjectsMap){
        list<Account> oldAccount = oldObjects;
        Map<Id,Id> accountIdmap = new Map<Id,Id>();        
        Map<Id,Account> newAccountMap = new Map<Id,Account>();
        for(sObject sObj:newObjectsMap.values()){
            
            Account accnt = (Account)sObj;
           
            newAccountMap.put(accnt.Id,accnt);
            
        }
           for(Account acc:oldAccount){
            if(acc.ownerId != newAccountMap.get(acc.Id).ownerId){
                accountIdmap.put(acc.Id,acc.Id);
            }
           }
           //List<AccountShare> acctShareList = [SELECT AccountId FROM AccountShare where AccountId in:accountIdmap.keySet()];
           
           if(!Test.isRunningTest()){
             if(accountIdmap.size()>0){
                 SIHelper.createSPSharingPartnerRule('AccountShare',accountIdmap);
             }
           }
    }
    
    public void checkLeadConversionFlagsTrue(SObject[] updatedObjects)
    {
        list<Account> accList = updatedObjects;
        
        for(Account account : accList)
        {       
            account.Network_Status__c= true;
            account.Trouble_Tickets__c= true;
            account.Service_Level_Agreements__c= true;
            account.Billing__c= true;      
        }
    }
    
    public void ChangeBillingAndServiceStatusOnContact(SObject[] updatedObjects,SObject[] oldObjects)
    {
        list<Account> accList = updatedObjects;
        list<Account> oldaccList = oldObjects;
        List<Contact> contactLst = new List<Contact>();
        set<ID> accID = new set<ID>();
        List<contact> updateConLst = new List<Contact>();  
        
            for(Account account : accList)
            {       
                accID.add(account.id);      
            }
            
            contactLst = [select accountid,Manage_Billing__c,Service_Assurance__c,Service_Assurance_Status__c,Billing_Status__c from Contact where AccountID IN: accID];
            
            for(Account account : accList){
                
                for(Contact con : contactLst){
                    if(con.accountid == account.id){
                        if(account.Billing__c == true){
                            if(con.Manage_Billing__c){
                                con.Billing_Status__c = 'Requested';
                                
                            }
                        }
                        else{
                            con.Billing_Status__c = 'Revoked';
                            
                        }
                        
                        if(account.Trouble_Tickets__c && account.Service_Level_Agreements__c && account.Network_Status__c){
                            if(con.Service_Assurance__c){
                                con.Service_Assurance_Status__c = 'Requested';
                                
                            }                       
                        }
                        else{
                            con.Service_Assurance_Status__c = 'Revoked';
                            
                        }
                        updateConLst.add(con);
                    }
                    
                }
            }
        update updateConLst;
    }
    
    public void ChangeBillingAndServiceStatusOnContactAfterUpdate(SObject[] updatedObjects,SObject[] oldObjects)
    {
        list<Account> accList = updatedObjects;
        list<Account> oldaccList = oldObjects;
        List<Contact> contactLst = new List<Contact>();
        set<ID> accID = new set<ID>();
        
        List<contact> updateConLst = new List<Contact>();
        
        
            for(Account account : accList)
            {       
                accID.add(account.id);      
            }
             for( Integer i=0; i<accList.size(); i++){
                if(accList[i].Billing__c != oldaccList[i].Billing__c || accList[i].Trouble_Tickets__c != oldaccList[i].Trouble_Tickets__c || accList[i].Service_Level_Agreements__c != oldaccList[i].Service_Level_Agreements__c || accList[i].Network_Status__c != oldaccList[i].Network_Status__c){  
                    contactLst = [select accountid,Manage_Billing__c,Service_Assurance__c,Service_Assurance_Status__c,Billing_Status__c from Contact where AccountID IN: accID];
                    break;
                    }
             }
            
            for( Integer i=0; i<accList.size(); i++){
                if(accList[i].Billing__c != oldaccList[i].Billing__c || accList[i].Trouble_Tickets__c != oldaccList[i].Trouble_Tickets__c || accList[i].Service_Level_Agreements__c != oldaccList[i].Service_Level_Agreements__c || accList[i].Network_Status__c != oldaccList[i].Network_Status__c){  
                    for(Contact con : contactLst){
                        if(con.accountid == accList[i].id){
                            if(accList[i].Billing__c == true){
                                if(con.Manage_Billing__c){
                                    con.Billing_Status__c = 'Requested';
                                    
                                }
                            }
                            else{
                                con.Billing_Status__c = 'Revoked';
                                
                            }
                            
                            if(accList[i].Trouble_Tickets__c && accList[i].Service_Level_Agreements__c && accList[i].Network_Status__c){
                                if(con.Service_Assurance__c){
                                    con.Service_Assurance_Status__c = 'Requested';
                                    
                                }                       
                            }
                            else{
                                con.Service_Assurance_Status__c = 'Revoked';
                                
                            }
                            updateConLst.add(con);
                        }
                        
                    }
                }
            }
        update updateConLst;
    }
    
    /*
    
    Added as part of US780973
    
    */
    public void updateAccountForASE(SObject[] oldObjects,SObject[] newObjects){
            List<Account> newAccountObj=newObjects;
             List<Account> oldAccountObj=oldObjects;
            Account currentAccount=[select id,Name,No_Of_Active_BAN__c,No_Of_Active_CNM__c,ASE_Product__c,ASE_ACNA__c,ASE_Ordering_Type__c from Account where id=:newAccountObj[0].id];
            if(oldAccountObj[0].ASE_Product__c && newAccountObj[0].ASE_Product__c){
            if(!(currentAccount.ASE_Ordering_Type__c!=null && currentAccount.ASE_ACNA__c!=null && currentAccount.ASE_ACNA__c!=''))
            {
            currentAccount.ASE_Product__c=False;
            update currentAccount;
            }
           }
           if(!oldAccountObj[0].ASE_Product__c && newAccountObj[0].ASE_Product__c){
                if(currentAccount.ASE_Ordering_Type__c==null || currentAccount.ASE_ACNA__c==null || currentAccount.ASE_ACNA__c=='' || currentAccount.No_Of_Active_BAN__c==0 || currentAccount.No_Of_Active_CNM__c==0){
                   newAccountObj[0].addError(' Key attributes are missing. Please check if CNUM, BAN, ACNA and ASE Ordering Type are populated.');                      
            }
           } 
    }
}