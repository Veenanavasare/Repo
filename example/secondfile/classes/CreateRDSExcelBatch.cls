global class CreateRDSExcelBatch implements Database.Batchable<sObject>,Database.stateful{
  //global String quoteId;
  global String dhId;
  global Decimal OpptyVersion;
  global RDSExcelController handler;
  global Id opptyId;
  global boolean varRun;
  global string ExecuteException;
  global boolean firstRun;
  //global Apttus_Proposal__Proposal__c quoteObj;
  global Opportunity oppObj;
//public RDSExcelController handler;
     
   global Database.QueryLocator start(Database.BatchableContext BC){
      try{
          oppObj = new Opportunity();
          oppObj = [Select Id,ATOM_Deal__c ,name,Service_type__c,RDS_Deal_Hash__r.id,RDS_Version__c,MACD_Type__c,Product_Name__c  from Opportunity where Id=: opptyId]; 
          opptyId = oppObj.Id;
          dhId= oppObj.RDS_Deal_Hash__r.id;
          OpptyVersion= oppObj.RDS_Version__c;
          System.debug('1: CPU Value NOW  :' + Limits.getCpuTime() + 'consumed of  :'+ Limits.getLimitCpuTime());
          String soqlQuery='select Premise_Friendly_Name__c,Remarks__c,IPFLEX__c,Premise_Number__c,DealHash__c,RDS_Version__c,Customer_Purchase_Decision_Date__c,Request_Due_Date__c,Planned_Turn_up_Date__c,Working_Telephone_Number__c,Notes__c,MLDB_Street_Number__c,MLDB_Street_Direction__c,MLDB_Street_Name__c,MLDB_Street_Type__c,MLDB_Street_Trailing_Direction__c,MLDB_Building__c,MLDB_Floor__c,MLDB_Room__c,MLDB_City__c,MLDB_State__c,MLDB_Zipcode__c,MLDB_Zipcode_Extension__c,MLDB_Country__c,Transport_Type__c,VLAN_Count__c,(Select Id,Contact_Type__c,RDS_Premise_Details_Number__r.id,RDS_Premise_Details_Number__c,Contact_First_Name__c,Contact_Last_Name__c,Contact_Phone__c,Contact_Email__c from RDS_Contact__r) from RDS_Premise_Details__c where  DealHash__c =:dhId AND RDS_Version__c =: OpptyVersion';
          System.debug('CreateRDSExcelBatch ^start^running soqlQuery:'+soqlQuery);
          varRun = true;
         
          firstRun =  true;
          return Database.getQueryLocator(soqlQuery);
      
     }catch(Exception exp){
                System.debug('3: CPU Value NOW  :' + Limits.getCpuTime() + 'consumed of  :'+ Limits.getLimitCpuTime());
                System.debug('error message: '+exp.getMessage()+'Line number: '+exp.getLineNumber());  
                ExecuteException = 'Exception:'+exp.getMessage()+' while iterating over premises in the batch at'+exp.getLineNumber()+exp;
                RDSExcelExceptionHandling ctrl = new RDSExcelExceptionHandling();
                system.debug('$$$$$$$$'+ExecuteException);
               if(!string.isBlank(ExecuteException)){
                 system.debug('$$$$$$$$'+ExecuteException);
                 varRun = false;
                 ctrl.changeOpptyStatus(opptyId, 'Failed', ExecuteException,oppObj.name);
                }
                return null;     
        }   
  }
   global void execute(Database.BatchableContext BC, List<sObject> scope){
     if(firstRun){
         String fType='';
            if(oppObj.MACD_Type__c == 'A'){
               fType = 'Add Sites';
            }
            else {
                fType = 'New Start';
            }
            string serviceType;
            //if(!oppObj.ATOM_Deal__c){
            serviceType = [select Id,recordtype.name from SPProduct__c where Deal__c =:oppObj.Id][0].recordtype.name;
                if(serviceType == 'MIS'){serviceType = 'AMIS';}
           /* }
            else{serviceType  = oppObj.Service_type__c;}*/
            handler = new RDSExcelController(oppObj.Id,serviceType,fType );
         system.debug('CreateRDSExcelBatch ^Database.QueryLocator start^handler.flowType :'+handler.flowType +' handler.product  :'+handler.product+'serviceType : '+serviceType );
         firstRun = false;
     }
     if(varRun==true){
     
     System.debug('CreateRDSExcelBatch ^start^got handler for RDSExcelController:'+handler);
     List<RDS_Premise_Details__c> premList= scope;
     try{
     for(RDS_Premise_Details__c prem:premList){
       /** Map<Id,string> exceptionMap;
        exceptionMap.get('123');**/
     System.debug('CreateRDSExcelBatch ^execute^Calling for premise:'+prem+' at sectionColId:'+handler.sectionColId);
         handler.populatePremise(prem);
         handler.sectionColId++;
         }
     }
     catch(Exception e){
         system.debug('Exception while attaching excel'+e);
         ExecuteException = 'Exception while iterating over premises in the batch at'+e.getLineNumber()+e;
         //RDSExcelExceptionHandling ctrl = new RDSExcelExceptionHandling();
         //ctrl.changeOpptyStatus(opptyId, 'Failed',true,'Exception while attaching excel'+e);
         //ctrl.changeOpptyStatus(opptyId, 'Failed', ExecuteException,oppObj.name);
         varRun = false;
       }
     }
    }
   global void finish(Database.BatchableContext BC){
       RDSExcelExceptionHandling ctrl = new RDSExcelExceptionHandling();
       system.debug('$$$$$$$$'+ExecuteException);
       if(!string.isBlank(ExecuteException)){
       system.debug('$$$$$$$$'+ExecuteException);
           varRun = false;
           ctrl.changeOpptyStatus(opptyId, 'Failed', ExecuteException,oppObj.name);
       }
       else{
           try{
             handler.attachCSVtoOppty();
             System.debug('CreateRDSExcelBatch ^finish^Calling for attachCSVtoOppty:');   
             ctrl.changeOpptyStatus(opptyId, 'Complete', '',null);
             }
           catch(Exception ex){
             //varRun = true;
             system.debug('Exception while attaching excel at'+ex);
             ExecuteException = 'Exception while attaching excel at'+ex.getLineNumber()+ex;
             ctrl.changeOpptyStatus(opptyId, 'Failed' ,'Exception while attaching excel'+ex,oppObj.name);
         }
      } 
   }

}