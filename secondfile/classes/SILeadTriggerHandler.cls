/* 
 Name: SITriggerOperations.SITriggerImpl
 Type: Class 
 
 Description: 
 */ 
public with sharing class SILeadTriggerHandler extends SITriggerOperations.SITriggerImpl {
    
    public boolean isExecuted ;

    //Default cons
/* 
 Name: SILeadTriggerHandler
 Description: 
 */ 
    public SILeadTriggerHandler() {
        isExecuted = true;
    }
    
/* 
 Name: onBeforeUpdate
 Description: 
 */ 
       public override boolean onBeforeUpdate(SObject[] oldObjects, SObject[] updatedObjects, Map<Id, SObject>  newObjectsMap )  {
        try {
            
            Leadcreditcheckconversion(updatedObjects);
            leadSourceEnhancements(oldObjects,updatedObjects,false);
            leadBusinessDevelopmentOwner(oldObjects,updatedObjects);
            Leadwithassociatedcontacts(updatedObjects);
            String obj=UtilityConstant.LEAD;
            String event=UtilityConstant.STATIC_UPDATE;
            SIWFEngineUtility.getInstance().Rulescoringengine(obj,event,oldObjects,updatedObjects);
            leadBillingInformation(updatedObjects);
            CopyFieldsonLead(updatedObjects);
                
        } catch(Exception excep) {
            isExecuted = false;
            throw excep;
        }
        return isExecuted;
    }
    
/* 
 Name: onBeforeInsert
 Description: 
 */ 
     public override boolean onBeforeInsert(SObject[] updatedObjects)  {
        try {
            String obj=UtilityConstant.LEAD;
            String event=UtilityConstant.STATIC_INSERT;
            SIWFEngineUtility.getInstance().Rulescoringengine(obj,event,updatedObjects,updatedObjects);
            leadBillingInformation(updatedObjects);
            CopyFieldsonLead(updatedObjects);
            leadSourceEnhancements(null,updatedObjects,true);
            
        } catch(Exception excep) {
            isExecuted = false;
            throw excep;
        }
        return isExecuted;
    }
    
/* 
 Name: onAfterUpdate
 Description: 
 */ 
    public override boolean onAfterUpdate(SObject[] oldObjects, SObject[] updatedObjects, Map<Id, SObject>  newObjectsMap )  {
    
    try {
            
            //DeleteContact(updatedObjects);
                
        } catch(Exception excep) {
            isExecuted = false;
            throw excep;
        }
        return isExecuted;
    
    }
    
    
/* 
 Name: Leadcreditcheckconversion
 Description: 
 */ 
   public void leadcreditcheckconversion (SObject[] updatedObjects){
        
    List<Lead> leadNewlist = updatedObjects;
    List<Credit_Validation__c> cVList=new List<Credit_Validation__c>();
    List<Certification__c> cFList=new List<Certification__c>();
    List<Related_Documents__c> docList=new List<Related_Documents__c>();
    List<Contact> contactList=new List<Contact>();
    List<Account> accountList = new List<Account>();
    List<Contact> contactDeleteList=new List<Contact>();
    List<Source__c> sourceList = new List<Source__c>();
    Map<Id,Id> leadMap = new Map<Id,Id>();
    List<ID> convertIDs=new List<ID>();
    List<ID> convertAccIDs=new List<ID>();
    RecordType recordtype= [Select r.SobjectType, r.Name, r.Id From RecordType r where r.SobjectType='Contact' and r.Name='Standard Contact'];
       
    //getting the Lead IDs which converted to Account & also creating Map between Lead ID,ConvertedAccountID
        for (lead LL:leadNewlist)
        {
          if (LL.isConverted)
           {
                convertIDs.add(LL.id);
                convertAccIDs.add(LL.ConvertedAccountID);
                LeadMap.put(LL.id,LL.ConvertedAccountID);

           }
        }  
        //getting the CV & CF & LeadSourceList list which needs to update.
        CVList = [select id,SP_Lead__c,SP_Account__c from Credit_Validation__c v where SP_Lead__c in :convertIDs];
        CFList = [select id,Lead__c,Who_Passed__c from Certification__c v where Lead__c in :convertIDs];
        DocList =[select id,Lead__c,Account__c from Related_Documents__c where Lead__c in : convertIDs];
        ContactList=[select id,Lead__c,AccountId  from Contact where Lead__c in :convertIDs];
        accountList=[Select ID,Description,MRA_Number__c from Account where ID IN:convertAccIDs]; 
        ContactDeleteList=[select id,Lead__c,AccountId  from Contact where Lead__c=null and AccountId in :convertAccIDs];
        SourceList=[select id,Lead__c,Account__c from Source__c where Lead__c in : convertIDs];
       //Assigning ConvertedAccountID to CV & CF
       
       /** Below code added to fix the ORT defect related to lead to account conversion**/
        Map<Id,Id> parentAccountMap = new Map<Id,Id>();
             
        for(Account acc: accountList){
            parentAccountMap.put(acc.Id,acc.Id);                    
        }
        if(parentAccountMap.size() > 0) {        
            SIHelper.createSPSharingPartnerRule(SIConstants.ACCOUNT_SHARE,parentAccountMap);
        }
       /* End of ORT defect Fix */
       
        for(Source__c ls:SourceList){
            ls.Account__c=LeadMap.get(ls.Lead__c);
        }
          for(Credit_Validation__c cv:CVList){
            cv.SP_Account__c=LeadMap.get(cv.SP_Lead__c);
          }
          for(Certification__c cf:CFList){
            cf.Who_Passed__c=LeadMap.get(cf.Lead__c);
          }
          for(Related_Documents__c rd:DocList){
            rd.Account__c=LeadMap.get(rd.Lead__c);
          }
          for(Contact ct:ContactList){
            ct.AccountId =LeadMap.get(ct.Lead__c);
            ct.RecordTypeId=recordtype.Id;
            ct.isconverted__c=true;
          }
          for(Contact ct:ContactDeleteList){
            
            ct.SIDeleteContact__c=true;
            ct.Primary_Contact__c=false;
            ct.accountId=null;
          }
          for(Lead leadUpdate:leadNewlist)
             for(Account acct:accountList){
             if(leadUpdate.ConvertedAccountID==acct.ID){
               acct.Description=leadUpdate.Description;
               acct.MRA_Number__c=leadUpdate.MRA_Number__c;
               }
          }
        //updating CV,CF,Doc,LeadSourceList and Contact List
        try{
            update SourceList;
            update CVList;
            update CFList;
            update DocList;
            update ContactList;
            update ContactDeleteList;
            update accountList; 
        }
        catch(Exception Ex)
        {
            ATTException.logException( Ex.getTypeName(), ATTException.constructExceptionMessageString(Ex));
        }
        
    }
/* 
 Name: leadBusinessDevelopmentOwner
 Description: 
 */       
   public void leadBusinessDevelopmentOwner(SObject[] oldObjects,SObject[] updatedObjects)
    {
        try{
        list<Lead> oldLeadList = oldObjects;
        list<Lead> newLeadList = updatedObjects;
        list<QueueSobject> queue = [select QueueId FROM QueueSobject];
        if(!newLeadList.isEmpty() && newLeadList!= null)
        {
            for (Integer i=0; i<newLeadList.size(); i++)
            {
                for(Integer j=0; j<queue.size(); j++)
                {
                    if(newLeadList[i].OwnerId == queue[j].QueueId && newLeadList[i].MRA_Executed_Date__c!=null)
                    {
                        newLeadList[i].addError('Lead Owner must not be a Queue when MRA has been executed');
                    }
                    if(oldLeadList[i].MRA_Executed_Date__c!=newLeadList[i].MRA_Executed_Date__c && newLeadList[i].MRA_Executed_Date__c!=null)
                    {
                            newLeadList[i].Business_Development_Owner__c=newLeadList[i].OwnerID;
                    } 
                    if(newLeadList[i].OwnerId == queue[j].QueueId && newLeadList[i].OwnerId !=oldLeadList[i].OwnerId)
                    {
                        newLeadList[i].addError('Lead Owner must Not be Changed to BID Lead Queue Again');
                    }
                }  
            }
        }
    }
    catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
} 
    
    //Lead validation check when lead status is SP Profile Completed
/* 
 Name: Leadwithassociatedcontacts
 Description: 
 */ 
   public void  leadwithassociatedcontacts(Sobject[] updateObjects)
    {
        try{
        List<Lead> leadNewList = updateObjects;
        Map<ID,Boolean> leadprimaryMap= new Map<ID,Boolean>();
        Map<ID,Boolean> leadMainContactMap= new Map<ID,Boolean>();
        Map<ID,Boolean> leadPoratlMap= new Map<ID,Boolean>();
        list<Contact> contactList= new list<Contact>();
        set<Id> leadId=new set<Id>();
        Integer pc,mc,pbc; 
         
        for(Lead lead:leadNewlist)
        {
            if(lead.Status == SIConstants.Lead_Status_SPProfileCompleted)
            {
                leadId.add(lead.id);
            }    
        }
        contactList =[Select Primary_Contact__c,Role__c,Lead__c,Id from Contact where Lead__c IN :leadId ];
        
        for(Lead lead1 : leadNewList)
        {
            pc=0;mc=0;pbc=0;
            for(Contact con : contactList)
            {
                if(lead1.Id == con.lead__c)
                {
                    if(con.Primary_Contact__c==true)
                    {
                        pc++;
                    }
                    if(con.Role__c!=null){
                        if(con.Role__c.contains(SIConstants.Contact_Roll_MainContact)){
                            mc++;
                        }
                    }
                    if(con.Role__c!=null){
                        if(con.Role__c.contains(SIConstants.Contact_Roll_PrimaryBilling))
                        {
                            pbc++;
                        }
                    }
                }
            }
            if(pc>0)
            {
                leadprimaryMap.put(lead1.Id,true);
            }
            if(mc>0)
            {
                leadMainContactMap.put(lead1.Id,true);
            }
            if(pbc>0)
            {
                leadPoratlMap.put(lead1.Id,true);
            }
        }   
        
        for(Lead lead2 : leadNewList)
        {
            if(leadId.contains(lead2.ID) && leadprimaryMap.get(lead2.Id)==null)
            {
                lead2.addError('Lead must contain a Portal Administrator in order to update Lead Status to SP Profile Completed');
            }
            if(leadId.contains(lead2.ID) && leadMainContactMap.get(lead2.Id)==null)
            {
                lead2.addError('Lead must contain a Main Contact in order to update Lead Status to SP Profile Completed');
            }
            if(leadId.contains(lead2.ID) && leadPoratlMap.get(lead2.Id)==null)
            {
                lead2.addError('Lead must contain a Primary Billing Contact in order to update Lead Status to SP Profile Completed');
            }       
       }
  }
  catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
} 
       
   /*Copy Lead one Feild to antoher Feild */  
   /* 
 Name: CopyFieldsonLead
 Description: 
 */
   public void copyFieldsonLead (SObject[] updatedObjects)
    {
        try{
        List<Lead> lNewlist = updatedObjects;
       for(Integer i=0;i<LNewlist.size();i++)
       {  

          if(LNewlist[i].Bus_Dev_Comment__c!=null)
              {
               if(LNewlist[i].Additional_information__c!=null){
                LNewlist[i].Additional_information__c = '['+Datetime.now().format()+'-'+ Userinfo.getName() + ']: \n '+ LNewlist[i].Bus_Dev_Comment__c+'\n\n'+LNewlist[i].Additional_information__c;
                }
                else{
                LNewlist[i].Additional_information__c = '['+Datetime.now().format()+'-'+ Userinfo.getName() + ']: \n'+ LNewlist[i].Bus_Dev_Comment__c;
                }
                LNewlist[i].Bus_Dev_Comment__c=null;
                
                if(LNewlist[i].Additional_information__c.Length()>32700){
                
                    LNewlist[i].Additional_information__c =LNewlist[i].Additional_information__c.substring(0,32700);
                
                }
                
                
            }
    
       }
       
   } 
catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}   
  /* 
 Name: leadBillingInformation
 Description: 
 */ 
    public void leadBillingInformation(SObject[] updatedObjects)
    {
        try{
        list<Lead> leadList = updatedObjects;
        
        for(Lead lead : leadList)
        {
            if(lead.Billing_Same_as_Company_Address__c)
            {
                lead.Billing_Address__c=lead.Street;
                lead.Billing_City__c=lead.City;
                lead.Billing_Zip_Code__c=lead.PostalCode;
                lead.Billing_State__c=lead.State;
                lead.Billing_Same_as_Company_Address__c=false;
            }
        }
    }
    catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
} 
    
    //Lead Soucre enhancement on "How did you learn about Partner Exchange?" field updation.
 /* 
 Name: leadSourceEnhancements
 Description: 
 */ 
    public void leadSourceEnhancements(SObject[] oldObjects,SObject[] updatedObjects,Boolean isInsert)
    {
        try{
        list<Lead> oldList = oldObjects;        
        list<Lead> updatedList = updatedObjects;
        list<Lead> newList = new List<Lead>();
        list<Source__c> sourcelist = new list<Source__c>();
        ID profileId = userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId limit 1].Name;
        Set<Id> leadId = new Set<Id>();
        Map<Id,Boolean> intialSouceCheck = new Map<Id,Boolean>();
        
        for(Lead lead : updatedList)
        {
            leadId.add(lead.Id);
        }
        
        sourcelist = [select Id,Initial_Source__c,Lead__c from Source__c where Lead__c IN :leadId];
        
        for(Source__c source : sourcelist)
        {
            if(source.Initial_Source__c)
            {
                intialSouceCheck.put(source.Lead__c,true);
            }
        }
        
        for(Lead lead : updatedList)
        {
            if(isInsert && lead.How_did_you_learn_about_AT_T_Partner_Exc__c!=null)
            {
                newList.add(lead);              
            }
        }
        
        for(Integer i=0; i<updatedList.size(); i++)
        {
            if(!isInsert && oldList[i].How_did_you_learn_about_AT_T_Partner_Exc__c == Null && updatedList[i].How_did_you_learn_about_AT_T_Partner_Exc__c!=null)
            {
                newList.add(updatedList[i]);
            }
        }
        
        for(Lead lead : newList)
        {
            Source__c source = new Source__c();
            source.Validation_Flag__c=true;
            source.Lead__c=lead.Id;
            source.Source_Type__c=lead.How_did_you_learn_about_AT_T_Partner_Exc__c;
            if(source.Source_Type__c.equals(SIConstants.Source_Type_Other))
            {
                source.If_Other_please_specify__c=lead.Other_Method__c;
            }
            else
            {
                source.Source_Detail__c=lead.Other_Method__c;
            }
            if(profileName!=SIConstants.System_Administrator || profileName!=SIConstants.SI_API_User)
            {
                source.Record_Origin__c=SIConstants.Record_Origin_UserCreated;
                if(intialSouceCheck.get(lead.Id)==true)
                {
                    source.Initial_Source__c=true;
                }
                source.Date_of_Interaction__c=System.today();
            }
            insert source;
        }
    }
    catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
} 
}