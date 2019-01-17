public Class API_DHStatus_AccessTest_TriggerHandler  extends SITriggerOperations.SITriggerImpl{

    public override boolean onAfterInsert (SObject[] newObjects){        
         try{ 
             populatePTAReceivedDateonUpdateIDH(newObjects);
            }        
         catch (exception e){
                e.getMessage();        
          } 
         return true;    
      } 
      
      public override boolean onAfterDelete(SObject[] oldObjects, Map<Id, SObject>  oldObjectsMap){        
         try{ 
             clearPTAReceivedonupdateIDH(oldObjects);
            }        
         catch (exception e){
                e.getMessage();        
          } 
         return true;    
      }

// Method to derive PTA Received Status on DHStatus-Update Deal Hash Details from Provider Sent Date Time on DHStatus-Access Test Status Details where Record Type = C
      
      /*  public void populatePTAReceivedDate(SObject[] newObjects){
        List<DHStatus_Access_Test_Status_Details__c> listOfAccessTest = newObjects;
        Map<Id,DHStatus_Access_Test_Status_Details__c> mapOfaccessTest = new Map<Id,DHStatus_Access_Test_Status_Details__c>();      
        List<DHStatus_Update_Deal_Hash_Details__c> listOfDhsTobeUpdated =new List<DHStatus_Update_Deal_Hash_Details__c>();
        List<DHStatus_Update_Deal_Hash_Details__c> listOfDhs =new List<DHStatus_Update_Deal_Hash_Details__c>();
        
            for(DHStatus_Access_Test_Status_Details__c atest:listOfAccessTest){
            system.debug('Values....'+(atest.Provider_Sent_Date_Time__c !=null));
            system.debug('Values1....'+(atest.Record_Type__c == 'C'));
            system.debug('Values2....'+(atest.ACTL_CLLI_on_ASR__c != null));
            system.debug('Values3....'+(atest.ACTL_CLLI_on_ASR__c != ''));
            String actlValue = atest.ACTL_CLLI_on_ASR__c;
            System.debug('Values4....'+actlValue);
            
                if(atest.Provider_Sent_Date_Time__c !=null && atest.Record_Type__c == 'C' && atest.ACTL_CLLI_on_ASR__c != null){
                    mapOfaccessTest.put(atest.DHStatus_Update_Deal_Hash_Details__c,atest);
                    system.debug('@#@#@$@$');
                    
                }       
            }
            
            if(mapOfaccessTest!=null || (!mapOfaccessTest.isEmpty())){
                listOfDhs = [Select id,PTA_Recieved__c from DHStatus_Update_Deal_Hash_Details__c where id in:mapOfaccessTest.keySet()];
            }
            
            if(listOfDhs.size()>0){
                for(DHStatus_Update_Deal_Hash_Details__c udhdObj : listOfDhs){                          
                    for(DHStatus_Access_Test_Status_Details__c test: mapOfaccessTest.values()){
                        if(test.DHStatus_Update_Deal_Hash_Details__c == udhdObj.Id){
                                      udhdObj.PTA_Recieved__c = test.Provider_Sent_Date_Time__c;
                                      listOfDhsTobeUpdated .add(udhdObj);
                                  }
                    }
                }
             }
                        
             if(listOfDhsTobeUpdated.size()>0){
                 try{
                     update listOfDhsTobeUpdated;
                 }Catch(Exception e){
                     e.getMessage();                    
                 }
                        
             }
        }
        public void clearPTAReceivedDate(SObject[] oldObjects){
        List<DHStatus_Access_Test_Status_Details__c> listOfAccessTest = oldObjects;
        Map<Id,DHStatus_Access_Test_Status_Details__c> mapOfaccessTest = new Map<Id,DHStatus_Access_Test_Status_Details__c>();      
        List<DHStatus_Update_Deal_Hash_Details__c> listOfDhsTobeUpdated =new List<DHStatus_Update_Deal_Hash_Details__c>();
        List<DHStatus_Update_Deal_Hash_Details__c> listOfDhs =new List<DHStatus_Update_Deal_Hash_Details__c>();
        
            for(DHStatus_Access_Test_Status_Details__c atest:listOfAccessTest){
                if(atest.Record_Type__c == 'C' && (atest.ACTL_CLLI_on_ASR__c != null || atest.ACTL_CLLI_on_ASR__c != '')){
                    mapOfaccessTest.put(atest.DHStatus_Update_Deal_Hash_Details__c,atest);                    
                }       
            }
            
            if(mapOfaccessTest!=null || (!mapOfaccessTest.isEmpty())){
                listOfDhs = [Select id,PTA_Recieved__c from DHStatus_Update_Deal_Hash_Details__c where id in:mapOfaccessTest.keySet()];
            }
            
            if(listOfDhs.size()>0){
                for(DHStatus_Update_Deal_Hash_Details__c udhdObj : listOfDhs){                          
                    for(DHStatus_Access_Test_Status_Details__c test: mapOfaccessTest.values()){
                        if(test.DHStatus_Update_Deal_Hash_Details__c == udhdObj.Id){
                                      udhdObj.PTA_Recieved__c = '';
                                      listOfDhsTobeUpdated .add(udhdObj);
                                  }
                    }
                }
             }
                        
             if(listOfDhsTobeUpdated.size()>0){
                 try{
                     update listOfDhsTobeUpdated;
                 }Catch(Exception e){
                     e.getMessage();                    
                 }
                        
             }
        
        
        } */

// Method to derive PTA Received on DHStatus-Update IDH from Provider Sent Date Time on DHStatus-Access Test Status Details where Record Type = C
      
        public void populatePTAReceivedDateonUpdateIDH(SObject[] newObjects){
        List<DHStatus_Access_Test_Status_Details__c> DHStatusLPList=newObjects;
        Set<String> DHStatusUDHDIDSet=new Set<String>();
        Set<String> DHStatusUDHDPremiseNumberSet=new Set<String>();
        List<DHStatus_Update_IDH__c> DHStatusUDHDList=new List<DHStatus_Update_IDH__c>();        
        Map<Id,DHStatus_Update_IDH__c> DHStatusUDHDMap=new Map<Id,DHStatus_Update_IDH__c>();
        for(DHStatus_Access_Test_Status_Details__c dast:DHStatusLPList)
        {
            if(dast.Provider_Sent_Date_Time__c!=NULL && dast.Record_Type__c=='C')
            {
                DHStatusUDHDIDSet.add(dast.DHStatus_Update_Deal_Hash_Details__c);
                //DHStatusUDHDPremiseNumberSet.add(dast.DHStatusUpdateDealHashPremiseNumber__c);
                
            }
        }
                        
        if(DHStatusUDHDIDSet.size()>0)
        {
            DHStatusUDHDList=[select Id,Data_Type__c,PTA_Received__c from DHStatus_Update_IDH__c WHERE Id IN:DHStatusUDHDIDSet];
        } 
        if(DHStatusUDHDList.size()>0)
        {
            for(DHStatus_Update_IDH__c udhd:DHStatusUDHDList)
            {
                for(DHStatus_Access_Test_Status_Details__c dhas:DHStatusLPList)
                {
                    if(udhd.id==dhas.DHStatus_Update_Deal_Hash_Details__c && dhas.Record_Type__c =='C' && udhd.Data_Type__c=='Port')
                        {
                          udhd.PTA_Received__c = dhas.Provider_Sent_Date_Time__c;
                          DHStatusUDHDMap.put(udhd.Id,udhd);  
                        }    
                }
            }
        }
      if(DHStatusUDHDMap.size()>0)
      {
          try
          {
          update DHStatusUDHDMap.Values();
          }
          Catch(Exception e)
          {
          }
      }         
  }  
        public void clearPTAReceivedonupdateIDH(SObject[] oldObjects){
        {
        List<DHStatus_Access_Test_Status_Details__c> DeleteDHStatusBUList=oldObjects;
        Map<String,DHStatus_Access_Test_Status_Details__c> DHStatusBUMap=new  Map<String,DHStatus_Access_Test_Status_Details__c>();
        Map<Id,DHStatus_Update_IDH__c> DHStatusUDHDMap=new Map<Id,DHStatus_Update_IDH__c>();
        
            for(DHStatus_Access_Test_Status_Details__c dhas:DeleteDHStatusBUList)
            {
                DHStatusBUMap.put(dhas.DHStatus_Update_Deal_Hash_Details__c ,dhas);
                system.debug('--@@--'+DHStatusBUMap);
            }          
            if(DHStatusBUMap!=NULL || !DHStatusBUMap.isEmpty())
            {
                for(DHStatus_Update_IDH__c udhd:[select Id,PTA_Received__c from DHStatus_Update_IDH__c WHERE Id IN:DHStatusBUMap.keySet()])
                {
                    udhd.PTA_Received__c=NULL;
                    DHStatusUDHDMap.put(udhd.Id,udhd);
                }
            }
           if(DHStatusUDHDMap.size()>0)
           {
               try
               {
                   update DHStatusUDHDMap.values();
               }
               Catch(Exception e)
               {
               }
           }                            
      }            
  }
}