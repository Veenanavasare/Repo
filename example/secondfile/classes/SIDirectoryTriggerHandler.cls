/* 
 Name: SITriggerOperations.SITriggerImpl
 Type: Class 
 
 Description: 
 */ 
public with sharing class SIDirectoryTriggerHandler extends SITriggerOperations.SITriggerImpl {
    
    public boolean isExecuted ;

    //Default cons
/* 
 Name: SIDirectoryTriggerHandler
 Description: 
 */ 
    public SIDirectoryTriggerHandler() {
        isExecuted = true;
    }
    
    //An Overridden method
/* 
 Name: onBeforeInsert
 Description: 
 */ 
    public override boolean onBeforeInsert(SObject[] newObjects) {
        try {
                updateDirectoryFields(newObjects);
                DirectoryAutoApproval(newObjects);
                CopyFieldsonDirectory(newObjects);
                     
        } catch(Exception excep) {
            isExecuted = false;
            throw excep;
        }
        return isExecuted;
    }
    
    //An Overridden method
/* 
 Name: onAfterInsert
 Description: 
 */ 
    public override boolean onAfterInsert(SObject[] newObjects) {
        try {  
              updateAccountFields(newObjects);
              checkDirectoryEntryNew(newObjects);
              DirectoryApproval(newObjects,newObjects,true); 
        } catch(Exception excep) {
            isExecuted = false;
            throw excep;
        }
        return isExecuted;
    }
    
    //An Overridden method
/* 
 Name: onBeforeUpdate
 Description: 
 */ 
    public override boolean onBeforeUpdate(SObject[] oldObjects,SObject[] newObjects,Map<Id,SObject> newObjectsMap) {
        try {
                updateDirectoryFields(newObjects);
                updateCurrentApproverAndTimeStamp(oldObjects,newObjects);
                CopyFieldsonDirectory(newObjects);
                UpdateDirectoryAutoApproval(newObjects,oldObjects);
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
    public override boolean onAfterUpdate(SObject[] oldObjects,SObject[] newObjects,Map<Id,SObject> newObjectsMap ){
        try
        {
            checkDirectoryEntryNew(newObjects);
            DirectoryApproval(newObjects,oldObjects,false);
        }
        catch(Exception e){
            //System.Debug(UtilityConstant.EXCEPTIONHERE_x+e.getMessage());
            isExecuted=false;
            throw e;
        }
        return isExecuted;    
    }
    
    //Business logic to update Marketing Consultant and Legal Reviewer when Account is Populated
    public void updateDirectoryFields(SObject[] newObjects)
    {
        try{
        list<Directory__c> newList = newObjects;
        set<Id> accountId = new set<Id>();
         
        for(Directory__c directory : newList)
        {
            if(directory.Account__c != null)
            {
                accountId.add(directory.Account__c);
            }
            //Business logic to update all multiselect picklist values to "BufferToStoreMultiPickVal" field such that field will be searchable in SOSL query.
            if(directory.Status__c==SIConstants.Status_Published)
            {
                directory.BufferToStoreMultiPickVal__c=directory.Industries__c+'\n'+directory.Region__c+'\n'+directory.Solutions__c+'\n'+directory.Number_of_Employees__c;
            }
        }
        
        list<Account> accList = [Select Id,Marketing_Consultant__c,Legal_Reviewer__c From Account Where Id IN :accountId];
        Admin_Control__c admincontrol = [Select Provider_Directory_Reviewer__c From Admin_Control__c LIMIT 1 ];
        
        for(Directory__c directory : newList)
        {
            for(Account account : accList)
            {
                if(directory.Account__c!=null && directory.Account__c == account.Id)
                {
                   if(account.Marketing_Consultant__c!=null ){
                    directory.Marketing_Consultant__c=account.Marketing_Consultant__c;
                    }else{
                        directory.Marketing_Consultant__c = admincontrol.Provider_Directory_Reviewer__c;
                    }
                  
                    directory.Legal_Reviewer__c=account.Legal_Reviewer__c;                    
                }                             
            }
        }
    }
    catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}
    
    //Business Logic To update Provider Directory Reviewer Field on Account From Admin Control if Directory Status is Pending Approval
    
/* 
 Name: updateAccountFields
 Description: 
 */ 
    public void updateAccountFields(SObject[] newObjects){
    try{
        list<Directory__c> newLists = newObjects;
        set<Id> accountId = new set<Id>();
         
        for(Directory__c directory : newLists)
        {
            if(directory.Account__c != null)
            {
                accountId.add(directory.Account__c);
            }        
        }
         list<Account> accLists = [Select Id,Marketing_Consultant__c From Account Where Id IN :accountId and Marketing_Consultant__c=:null];
        
            if(accLists!=null ){ 
            
                 Admin_Control__c admincontrols = [Select Provider_Directory_Reviewer__c From Admin_Control__c LIMIT 1 ];
             
                 for(Account account : accLists){
                   account.Marketing_Consultant__c = admincontrols.Provider_Directory_Reviewer__c;
                 }            
                 update accLists;     
           }    
         }
         catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}
    
    //Business logic to update Approver and Approval Timestamp when status is changed to Review Requested or Published
    public void updateCurrentApproverAndTimeStamp(SObject[] oldObjects,SObject[] newObjects)
    {
        try{
        list<Directory__c> oldDirectory = oldObjects;
        list<Directory__c> newDirectory = newObjects;
        
        for (Integer i=0; i<newDirectory.size(); i++)
        {
            if((newDirectory[i].Status__c!=null && oldDirectory[i].Status__c!=null) && (oldDirectory[i].Status__c==SIConstants.Status_Pending_Approval ||oldDirectory[i].Status__c==SIConstants.Status_Pending_Legal_Approval) && (newDirectory[i].Status__c==SIConstants.Status_Review_Requested || newDirectory[i].Status__c==SIConstants.Status_Published))
            {
                newDirectory[i].Approver__c=UserInfo.getUserId(); 
                newDirectory[i].Approval_Timestamp__c = system.Now();
            }
            //Business logic to update "Display On Landing Page" to false when status change from published to another status.
            if(oldDirectory[i].Status__c==SIConstants.Status_Published && newDirectory[i].Status__c != SIConstants.Status_Published && newDirectory[i].Display_On_Landing_Page__c)
            {
                newDirectory[i].Display_On_Landing_Page__c = false;
            }
        }
    }
    catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}
    //Business logic to make sure an SP contains only one dierectory record with status Published. If there are any other records for that SP with satus
    //published then we are archieving the old records and new record will remian same with status published.
    public void checkDirectoryEntryNew(SObject[] newObjects)
    {
        try{
        list<Directory__c> newDirectory = newObjects;
        set<Id> AccountIds = new Set<Id>();
        set<Id> DirectoryIds  = new Set<Id>();
        list<Directory__c> updateoldDirectory = new list<Directory__c>();
        
        for(Directory__c D: newDirectory){
            if((D.Status__c==SIConstants.Status_Published || D.Status__c==SIConstants.Status_Published_Pending_New_Version)&& D.Account__c!=null){
                    AccountIds.add(D.Account__c);
                    DirectoryIds.add(D.Id);
                }           
            }
        
        updateoldDirectory = [Select Id,Account__c,Status__c from Directory__c where (Status__c=:SIConstants.Status_Published or Status__c=:SIConstants.Status_Published_Pending_New_Version) and Account__c IN:AccountIds and Id Not IN:DirectoryIds];
        
        for(Directory__c updateDirec: updateoldDirectory){
            updateDirec.Restrict_Validation_Rule__c = True;
            updateDirec.Status__c=SIConstants.Status_Archived;
        }
            
        if(updateoldDirectory!=null){
            update updateoldDirectory;
        }
    }
    catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}
    
    public void CopyFieldsonDirectory (SObject[] updatedObjects)
    {
        try{
       List<Directory__c> LNewlist = updatedObjects;
       for(Integer i=0;i<LNewlist.size();i++)
       {  
          if(LNewlist[i].Additional_Information_Feedback__c!=null)
              {
               if(LNewlist[i].Feedback_History_Additional_Information__c!=null){
                LNewlist[i].Feedback_History_Additional_Information__c = '['+Datetime.now().format()+ ']: \n '+ LNewlist[i].Additional_Information_Feedback__c+'\n\n'+LNewlist[i].Feedback_History_Additional_Information__c;
                }
                else{
                LNewlist[i].Feedback_History_Additional_Information__c = '['+Datetime.now().format()+ ']: \n'+ LNewlist[i].Additional_Information_Feedback__c;
                }
               // LNewlist[i].Additional_Information_Feedback__c=null;
                
                if(LNewlist[i].Feedback_History_Additional_Information__c.Length()>32700){
                
                    LNewlist[i].Feedback_History_Additional_Information__c =LNewlist[i].Feedback_History_Additional_Information__c.substring(0,32700);
         
                }
            }
         
         if(LNewlist[i].Connect_Tab_Feedback__c!=null)
              {
               if(LNewlist[i].Feedback_History_Contact__c!=null){
                LNewlist[i].Feedback_History_Contact__c = '['+Datetime.now().format()+ ']: \n '+ LNewlist[i].Connect_Tab_Feedback__c +'\n\n'+LNewlist[i].Feedback_History_Contact__c;
                }
                else{
                LNewlist[i].Feedback_History_Contact__c = '['+Datetime.now().format()+ ']: \n'+ LNewlist[i].Connect_Tab_Feedback__c;
                }
               // LNewlist[i].Connect_Tab_Feedback__c =null;
                          
                if(LNewlist[i].Feedback_History_Contact__c.Length()>32700){
                
                    LNewlist[i].Feedback_History_Contact__c =LNewlist[i].Feedback_History_Contact__c.substring(0,32700);
         
                }
            }   
         
        if(LNewlist[i].Details_Tab_Feedback__c!=null)
              {
               if(LNewlist[i].Feedback_History_Details__c!=null){
                LNewlist[i].Feedback_History_Details__c = '['+Datetime.now().format()+ ']: \n '+ LNewlist[i].Details_Tab_Feedback__c +'\n\n'+LNewlist[i].Feedback_History_Details__c;
                }
                else{
                LNewlist[i].Feedback_History_Details__c = '['+Datetime.now().format()+ ']: \n'+ LNewlist[i].Details_Tab_Feedback__c;
                }
               // LNewlist[i].Details_Tab_Feedback__c =null;
                
                if(LNewlist[i].Feedback_History_Details__c.Length()>32700){
                
                    LNewlist[i].Feedback_History_Details__c =LNewlist[i].Feedback_History_Details__c.substring(0,32700);
         
                }
            }   
            
          if(LNewlist[i].Overview_Tab_Feedback__c!=null)
              {
               if(LNewlist[i].Feedback_History_Overview__c!=null){
                LNewlist[i].Feedback_History_Overview__c = '['+Datetime.now().format()+ ']: \n '+ LNewlist[i].Overview_Tab_Feedback__c +'\n\n'+LNewlist[i].Feedback_History_Overview__c;
                }
                else{
                LNewlist[i].Feedback_History_Overview__c = '['+Datetime.now().format()+ ']: \n'+ LNewlist[i].Overview_Tab_Feedback__c;
                }
               // LNewlist[i].Overview_Tab_Feedback__c =null;
                        
                if(LNewlist[i].Feedback_History_Overview__c.Length()>32700){
                
                    LNewlist[i].Feedback_History_Overview__c =LNewlist[i].Feedback_History_Overview__c.substring(0,32700);
         
                }
            }    
        
          if(LNewlist[i].Provider_Details_Feedback__c!=null)
              {
               if(LNewlist[i].Feedback_History_Provider_Details__c!=null){
                LNewlist[i].Feedback_History_Provider_Details__c = '['+Datetime.now().format()+ ']: \n '+ LNewlist[i].Provider_Details_Feedback__c +'\n\n'+LNewlist[i].Feedback_History_Provider_Details__c;
                }
                else{
                LNewlist[i].Feedback_History_Provider_Details__c = '['+Datetime.now().format()+ ']: \n'+ LNewlist[i].Provider_Details_Feedback__c;
                }
               // LNewlist[i].Provider_Details_Feedback__c =null;
                                
                if(LNewlist[i].Feedback_History_Provider_Details__c.Length()>32700){
                
                    LNewlist[i].Feedback_History_Provider_Details__c =LNewlist[i].Feedback_History_Provider_Details__c.substring(0,32700);
         
                }
            }    
        
       }
       
       
   }
   catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}
    
/* 
 Name: DirectoryApproval
 Description: 
 */ 
    public void DirectoryApproval(SObject[] newObjects,SObject[] oldObjects,Boolean dirInsert){
try{        
    List<Directory__c> PDNewList =newObjects;
    List<Directory__c> PDOldList =oldObjects;
    
    if(dirInsert){
    
        for(Directory__c D:PDNewList){
        
            if(D.Status__c == SIConstants.Status_Pending_Approval && D.Marketing_Consultant__c!=null && D.Legal_Reviewer__c!=null){
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Submitted for approval. Please approve.');
                req.setObjectId(D.Id);
                //req.setObjectId(Trigger.old[i].Id);
                // submit the approval request for processing
                Approval.ProcessResult result = Approval.process(req);
                // display if the reqeust was successful
            }
        }
    }
    
    else{
            for (Integer i = 0; i < PDNewList.size(); i++) {
                if (PDNewList[i].Status__c == SIConstants.Status_Pending_Approval && PDNewList[i].Status__c !=PDOldList[i].Status__c && PDNewList[i].Marketing_Consultant__c!=null && PDNewList[i].Legal_Reviewer__c!=null) {
                    
                    // create the new approval request to submit
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    req.setComments('Submitted for approval. Please approve.');
                    req.setObjectId(PDNewList[i].Id);
                    // submit the approval request for processing
                    Approval.ProcessResult result = Approval.process(req);  // display if the reqeust was successful                           
           }
         }
       }  
    }
    catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}
/* 
 Name: DirectoryAutoApproval
 Description: 
 */ 
    public void DirectoryAutoApproval(SObject[] newObjects){  
try{    
        List<Directory__c> directorylist = newObjects;
        List<Directory__c> DirDBList = new List<Directory__c>();
        set<Id> AccountId = new set<Id>();
        Map<Id,Directory__c> ACMap=new Map<Id,Directory__c>();
     
        for(Directory__c directory:directorylist ){
            AccountId.add(directory.Account__c);
        }
        
        if(!AccountId.isEmpty()&& AccountId!=null){
        
         DirDBList =  [Select Logo_Link__c,Marketing_Consultant__c,Approval_Timestamp__c,Demo_Video__c,Company_Display_Name__c,Tagline__c,Summary__c,Description__c,Account__c,Full_Size_Logo__c,Phone_Number_Secondary__c from Directory__c where Account__c IN :Accountid AND Status__c IN ('Published','Archived')  order by  LastModifiedDate desc ]; 
        
        }
        if(!DirDBList.isEmpty()&& DirDBList!=null){
            for(Directory__c DB :DirDBList ){
                if(ACMap.get(DB.Account__c)==null)
                {
                    ACMap.put(DB.Account__c,DB);
                }
             }
             for(Directory__c dir:directorylist){
                  if(ACMap.get(dir.Account__c)!=null){
                    if(dir.Company_Display_Name__c==ACMap.get((dir.Account__c)).Company_Display_Name__c 
                    && dir.Status__c ==SIConstants.Status_Pending_Approval
                    && dir.Tagline__c==ACMap.get((dir.Account__c)).Tagline__c
                    && dir.Logo_Link__c==ACMap.get((dir.Account__c)).Logo_Link__c 
                    && dir.Demo_Video__c==ACMap.get((dir.Account__c)).Demo_Video__c 
                    && dir.Summary__c==ACMap.get((dir.Account__c)).Summary__c 
                    && dir.Description__c==ACMap.get((dir.Account__c)).Description__c
                    && dir.Full_Size_Logo__c==ACMap.get((dir.Account__c)).Full_Size_Logo__c)                   
                    {
                        dir.Status__c=SIConstants.Status_Published;
                        dir.Approver__c = ACMap.get((dir.Account__c)).Marketing_Consultant__c;
                        dir.Approval_Timestamp__c = ACMap.get((dir.Account__c)).Approval_Timestamp__c;
                        dir.Auto_Approved__c = true;
                    }
                }
             }
        }
   }
   catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}

/* 
 Name: UpdateDirectoryAutoApproval
 Description: 
 */ 
public void UpdateDirectoryAutoApproval(SObject[] newObject,SObject[] oldObject){
    try{
            List<Directory__c> directorynewlist = newObject;
            List<Directory__c> directoryoldlist = oldObject;
            List<Directory__c> DirDBList = new List<Directory__c>();
            set<Id> AccountId = new set<Id>();
            for(Directory__c directory : directorynewlist)
            {
                AccountId.add(directory.Account__c);
            }
            if(!AccountId.isEmpty() && AccountId!=null)
            {
                DirDBList = [Select Region__c,Number_of_Employees__c,Solutions__c,Primary_Email_Address__c,Secondary_Email_Address__c,Website__c,Phone_Number__c,City__c,State__c,Country__c,Industries__c,Request_More_Information__c,Account__c from Directory__c where Account__c IN :Accountid AND Status__c IN ('Published')  order by  LastModifiedDate desc ]; 
            }
            if(!DirDBList.isEmpty()&&DirDBList != null){
              for (Integer i=0; i<directorynewlist.size(); i++)
              {
                if((directorynewlist[i].Region__c != directoryoldlist[i].Region__c) 
                 ||(directorynewlist[i].Number_of_Employees__c != directoryoldlist[i].Number_of_Employees__c)
                 ||(directorynewlist[i].Solutions__c != directoryoldlist[i].Solutions__c) 
                 ||(directorynewlist[i].Primary_Email_Address__c != directoryoldlist[i].Primary_Email_Address__c) 
                 ||(directorynewlist[i].Secondary_Email_Address__c != directoryoldlist[i].Secondary_Email_Address__c)
                 ||(directorynewlist[i].Website__c != directoryoldlist[i].Website__c)
                 ||(directorynewlist[i].Phone_Number__c != directoryoldlist[i].Phone_Number__c)
                 ||(directorynewlist[i].City__c != directoryoldlist[i].City__c)
                 ||(directorynewlist[i].State__c != directoryoldlist[i].State__c)
                 ||(directorynewlist[i].Country__c != directoryoldlist[i].Country__c)
                 ||(directorynewlist[i].Industries__c != directoryoldlist[i].Industries__c)
                 ||(directorynewlist[i].Request_More_Information__c != directoryoldlist[i].Request_More_Information__c))                
                {
                    directorynewlist[i].Status__c =SIConstants.Status_Published;
                    directorynewlist[i].Auto_Approved__c = true;
                    
                }
            }          
         }
     }
     catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}
 }