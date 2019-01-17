public with sharing class RecallButtonController
   {
    public string retURL3{get;set;}
    public string Status{get;set;}
    public Directory__c dirObj{get;set;}
    public Id dirId {get;set;}
    public Directory__c dir {get;set;}
    public String retURL2{get;set;} 
   // public String confToken {get;set;}
    public List<ProcessInstance> piList = new List<ProcessInstance>();
    public List<ProcessInstance> piLists = new List<ProcessInstance>();
    public Id swID {get;set;} 
    public String stageName {get;set;}
    public String legalReviewer {get;set;}
    public id providerDirectoryReviewer {get;set;} 
    public Boolean showRecallBtn {get;set;}
     public Boolean showRecallBtn1 {get;set;}
     public Boolean  condition2{get;set;} 
    public Id piId {get;set;}
    public String retURL {get;set;}
     public String retURL1 {get;set;}
    public List<ProcessInstanceWorkitem> pwItemList = new List<ProcessInstanceWorkitem>();
    public String profileName{get;set;}
     public id userid{get;set;}
     public String Username{get;set;}
    
    private ApexPages.StandardController standardController;

    public RecallButtonController(ApexPages.StandardController standardController)
    {
        condition2=false;
        userid=UserInfo.getUserId();
        Username=UserInfo.getName();
        system.debug('Username11'+Username);
       Id profileId=userinfo.getProfileId();
       if(profileId!=null)
       {
        profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        system.debug('ProfileName'+profileName);
        }
        
        showRecallBtn = false;
         showRecallBtn1 = true; 
        this.standardController = standardController;
           
          dir = (Directory__c)standardController.getRecord();
          system.debug('00000{{}}'+dir );
          dirId=dir.id;
           if(!String.isBlank(dirId)){
          dirObj=[select id,Status__c,Marketing_Consultant__c,Legal_Reviewer__c from Directory__c  where id=:dirId]; 
          system.debug('dirObj:-->'+dirObj);                   
        }
        if(dirObj!=null){
            If(!String.isBlank(dirObj.Status__c )){
                stageName=dirObj.Status__c;
                system.debug('dirObj:-->'+stageName);
           }
           If(!String.isBlank(dirObj.Marketing_Consultant__c)){
            providerDirectoryReviewer=dirObj.Marketing_Consultant__c;
            system.debug('dirObj:-->'+providerDirectoryReviewer);
          }
         system.debug('dirObj:legalReviewer-->'+legalReviewer);
          If(!String.isBlank(dirObj.Legal_Reviewer__c)){
              legalReviewer=dirObj.Legal_Reviewer__c;
               system.debug('dirObj:legalReviewer-->'+legalReviewer);
              }
              }
             
          piList=[SELECT Id,Status,TargetObjectId FROM ProcessInstance WHERE Status='Pending' AND TargetObjectId = :dirId ORDER BY  CreatedDate DESC];
          if( piList != null && piList.size() > 0 ){
              pwItemList = [SELECT id FROM ProcessInstanceWorkitem WHERE ProcessInstanceId =: piList[0].Id LIMIT 1 ];
              showRecallBtn = true;
              showRecallBtn1 = false;
          }else{ showRecallBtn = false;
                  showRecallBtn1 = true ;
                   }
          //piId=piList[0].Id;
          
    }
    

    public void recallForApproval(){
        //Apex code for handling record from a Detail page goes here
        //pageReference pr=new pageReference(piId+'/e?et=REMOVE&retURL=%2f'+dirId);
        //pr.setRedirect(true);
        if( pwItemList != null && pwItemList.size() > 0 ){
            retURL = Label.SIVAR_HOME+'/'+pwItemList[0].id+'/e?et=REMOVE&retURL=%2f'+dirId;
             system.debug('retURL:-->'+retURL);  
        }
    }
       public void submitForApproval(){
        //Apex code for handling record from a Detail page goes here
        //pageReference pr=new pageReference(piId+'/e?et=REMOVE&retURL=%2f'+dirId);
        //pr.setRedirect(true);
         
            retURL1 = Label.SIVAR_HOME+'/'+dirId;
            retURL2 = 'https://ebm.my.salesforce.com/apex/Errorpage?did='+dirId;
              
             if(stageName=='Pending Approval' && providerDirectoryReviewer==Userid )
             {
                 Approval.ProcessSubmitRequest req1 =new Approval.ProcessSubmitRequest();
                 
                                 req1.setObjectId(dirId);
                                 // Submit the approval request for the account
                           Approval.ProcessResult result = Approval.process(req1);

               }
           else if(stageName=='Pending Approval' && providerDirectoryReviewer!=Userid && ( profileName == 'System Administrator' || profileName == 'SI_EBM_DEV_OPS'|| profileName == 'SI_API User'|| profileName == 'System Admin Read Only(Developers/Testers)'|| profileName == 'SI_EBM Admin'|| profileName == 'SI_EBM BD & Sales SME'|| profileName == 'Developer Administrator'))
        {         
                      Condition2 = true;
                       system.debug('ProfileName1'+profileName);
                      system.debug('ProfileName1'+userid);
               Approval.ProcessSubmitRequest req1 =new Approval.ProcessSubmitRequest();
                 
                                 req1.setObjectId(dirId);
                                 // Submit the approval request for the account
                                 if(!Test.isRunningTest()){
                           Approval.ProcessResult result = Approval.process(req1);
                           }

 }else{}
    }
      //public void ReturnToRecord(){
      
       //retURL3 = Label.SIVAR_HOME+'/'+dirId;
       //system.debug('retURL3:-->'+retURL3);
    //}
}