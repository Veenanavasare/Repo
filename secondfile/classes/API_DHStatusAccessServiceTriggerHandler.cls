/* Component Name :API_DHStatusAccessServiceTriggerHandler      
Requirement/User Story Number :US290910 ; US311424     
Requirement Description:Derive fields on DHStatus-Update Deal Hash Details Object from DHStatus-Access Service Request Status object
Component Author:Accenture IDC     
Created Date:29th July 2014      
Version:1.0     
*/
public with sharing class API_DHStatusAccessServiceTriggerHandler extends SITriggerOperations.SITriggerImpl{
// To be used for Future after insert operations     
/* 
 Name: onAfterInsert
 Description: 
 */ 
     public override boolean onAfterInsert (SObject[] newObjects){        
         try{ 
             //String event = UtilityConstant.Static_INSERT;
             //updateProvisioningDates(newObjects);
             updateFOCDateChangedOnIDH(newObjects);
             UpdateDHStatusIDHFields(newObjects);
             //updateFocDateIndicator (newObjects, event);
            }        
         catch (exception e){
                e.getMessage(); 
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));   
          } 
         return true;    
      } 
      
   /*  public override boolean onAfterUpdate(SObject[] oldObjects, SObject[] newObjects, Map<Id, SObject>  newObjectsMap){
            try{
                //updateProvisioningDates(newObjects);
               }        
            catch (exception e){ 
                   e.getMessage();        
             }
            return true;    
      }*/
      
/* 
 Name: onAfterDelete
 Description: 
 */ 
     public override boolean onAfterDelete(SObject[] oldObjects, Map<Id, SObject>  oldObjectsMap){        
         try{ 
             //String event = UtilityConstant.DELETE;
             ClearFOCDateChangedOnIDH(oldObjects);
             ClearDHStatusIDHFields(oldObjects);
             //updateFocDateIndicator(oldObjects, event);
             //clearProvisioningDates(oldObjects);
            }        
         catch (exception e){
                e.getMessage(); 
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));   
          } 
         return true;    
      }  
     
 
     
    /*public void updateFocDateIndicator (SObject[] newObjects, String check){
        List<DHStatus_Access_Service_Request_Statuse__c> accessServiceList = newObjects;
        Set<String> asrIds = new Set<String>();
        Set<String> dhIds = new Set<String>();
        
        Map<String,DHStatus_Access_Service_Request_Statuse__c> dhAsrReqMap = new Map<String,DHStatus_Access_Service_Request_Statuse__c> (); 
        Map<String,DHStatus_Access_Service_Request_Statuse__c> dealhAsrMap = new Map<String,DHStatus_Access_Service_Request_Statuse__c> ();  
        List<DHStatus_Update_IDH__c> updatedhdList = new List<DHStatus_Update_IDH__c>();   
        Integer i = 0;
        Integer j = 0;
        Boolean fcRecord = false;
        //Boolean uniType = false;
        //Boolean evcType = false;
        
        for(DHStatus_Access_Service_Request_Statuse__c asrobj : accessServiceList){
                 if(asrobj.Status_Record_Type__c!=NULL && asrobj.Status_Record_Type__c==UtilityConstant.FC)
                 {
                 asrIds.add(asrobj.DHStatus_ASR_Details__c);
                 dhIds.add(asrobj.DHStatus_Update_IDH_ID__c);
                 }
         }
         
        if(asrIds.size()>0 && dhIds.size()>0){
            List<DHStatus_Access_Service_Request_Statuse__c> dhAccessList = [Select id,Status_Record_Type__c,DHStatus_ASR_Details__c,DHStatus_Update_IDH_ID__c from DHStatus_Access_Service_Request_Statuse__c WHERE Status_Record_Type__c = 'FC'];
            List<DHStatus_ASR_Details__c> asrdList = [Select id,Purchase_Order_Number__c,DHStatus_Update_IDH__c from DHStatus_ASR_Details__c where ID in: asrIds];
            List<DHStatus_Update_IDH__c> dhList = [select Id,Data_Type__c, FOC_Date_Changed_EVC_PON__c, FOC_date_Changed__c from DHStatus_Update_IDH__c where ID in: dhIds];
                for(DHStatus_Update_IDH__c udhdObj : dhList){
                    for(DHStatus_ASR_Details__c dhAsr : asrdList) {
                        for(DHStatus_Access_Service_Request_Statuse__c dhStatusobj : dhAccessList){
                            if(dhStatusobj.DHStatus_Update_IDH_ID__c == udhdObj.id && dhAsr.DHStatus_Update_IDH__c == udhdObj.id && dhStatusobj.DHStatus_ASR_Details__c == dhAsr.Id && dhStatusobj.Status_Record_Type__c == UtilityConstant.FC ){
                                i+=1;
                                
                                
                                //uniType = true;                        
                            }               
                            /*if(dhStatusobj.DHStatus_Update_IDH_ID__c == udhdObj.id && dhAsr.DHStatus_Update_IDH__c == udhdObj.id && dhStatusobj.DHStatus_ASR_Details__c == dhAsr.Id ){
                                j+=1;
                                //evcType = true;
                            } */ 
                       /* }
                    }
                }
                
                    for(DHStatus_Update_IDH__c dhd : dhList){
                        if(check == UtilityConstant.INSERT){
                            if(i>1 && dhd.Data_Type__c == UtilityConstant.PORT){                
                                dhd.FOC_date_Changed__c = UtilityConstant.YES;
                                updatedhdList.add(dhd);
                            }
                            if (i<=1 && dhd.Data_Type__c == UtilityConstant.PORT){
                                dhd.FOC_date_Changed__c = UtilityConstant.NO;
                                updatedhdList.add(dhd);
                            }
                            if(i>1 && dhd.Data_Type__c == UtilityConstant.VLAN){                
                                dhd.FOC_Date_Changed_EVC_PON__c = UtilityConstant.YES;
                                updatedhdList.add(dhd);
                            }
                            if (i<=1 && dhd.Data_Type__c == UtilityConstant.VLAN){                      
                                dhd.FOC_Date_Changed_EVC_PON__c = UtilityConstant.NO;
                                updatedhdList.add(dhd);
                            }
                        } else if(check == UtilityConstant.DELETE){
                            if(dhd.Data_Type__c == UtilityConstant.PORT){                
                               dhd.FOC_date_Changed__c = null;
                               updatedhdList.add(dhd);
                            }                      
                            if(dhd.Data_Type__c == UtilityConstant.VLAN){                
                                dhd.FOC_Date_Changed_EVC_PON__c = null;
                                updatedhdList.add(dhd);
                            }  
                        }
                    
                }
        }
        
        if(updatedhdList.size()>0){
            try{
                update updatedhdList;
            } catch(DMLException e){
                e.getMessage();
            }
        } 
    }*/
   /*Name:UpdateDHStatusIDHFields
    * Description:
    */
  public void updateDHStatusIDHFields(SObject[] newObjects)
  {
    try{  
      List<DHStatus_Access_Service_Request_Statuse__c> dHStatusASRSList=newObjects;
      Set<String> dHStatusIDSet=new Set<String>();
      List<DHStatus_Update_IDH__c> iDHList=new List<DHStatus_Update_IDH__c>();
      Map<Id,DHStatus_Update_IDH__c> iDHMap=new Map<Id,DHStatus_Update_IDH__c>();
      for(DHStatus_Access_Service_Request_Statuse__c dhasr:DHStatusASRSList)
      {
          if(dhasr.Status_Record_Type__c!=NULL)
          {
          DHStatusIDSet.add(dhasr.DHStatus_Update_IDH_ID__c);
          }
      }
          if(DHStatusIDSet.size()>0)
          {
           IDHList=[select Id,Firm_Order_Sent_UNI_PON__c,Data_Type__c,Firm_Order_Accepted_UNI_PON__c,FOC_Received_Date_UNI_PON__c,R84_Date_Received_UNI_PON__c,Access_in_Effect_Date__c,Firm_Order_Sent_EVC_PON__c,Firm_Order_Accepted_EVC_PON__c,FOC_Received_Date_EVC_PON__c,R84_Date_Received_EVC_PON__c from DHStatus_Update_IDH__c WHERE Id IN:DHStatusIDSet];   
          }
          if(IDHList.size()>0)
          {
             for(DHStatus_Update_IDH__c idh:IDHList)
             {
                 for(DHStatus_Access_Service_Request_Statuse__c asrs:DHStatusASRSList)
                 {
                     if(idh.id==asrs.DHStatus_Update_IDH_ID__c && idh.Data_Type__c==UtilityConstant.PORT && asrs.Status_Record_Type__c==UtilityConstant.FO)
                     {
                        idh.Firm_Order_Sent_UNI_PON__c= asrs.Update_Date_Time__c;
                        IDHMap.put(idh.id,idh);
                     }
                     else if(idh.id==asrs.DHStatus_Update_IDH_ID__c && idh.Data_Type__c==UtilityConstant.PORT && asrs.Status_Record_Type__c==UtilityConstant.FA)
                     {
                         idh.Firm_Order_Accepted_UNI_PON__c=asrs.Update_Date_Time__c;
                         IDHMap.put(idh.id,idh);
                     }
                     else if(idh.id==asrs.DHStatus_Update_IDH_ID__c && idh.Data_Type__c==UtilityConstant.PORT && asrs.Status_Record_Type__c==UtilityConstant.FC)
                     {
                         idh.FOC_Received_Date_UNI_PON__c=asrs.Update_Date_Time__c;
                         IDHMap.put(idh.id,idh);
                     }
                     else if(idh.id==asrs.DHStatus_Update_IDH_ID__c && idh.Data_Type__c==UtilityConstant.PORT && asrs.Status_Record_Type__c==UtilityConstant.FJ &&  asrs.Jeopardy_Code__c==UtilityConstant.R84)
                     {
                         idh.R84_Date_Received_UNI_PON__c=asrs.Update_Date_Time__c;
                         IDHMap.put(idh.id,idh);
                     }
                     else if(idh.id==asrs.DHStatus_Update_IDH_ID__c && idh.Data_Type__c==UtilityConstant.PORT && asrs.Status_Record_Type__c==UtilityConstant.ZI)
                     {
                         idh.Access_in_Effect_Date__c=asrs.Update_Date_Time__c;
                         IDHMap.put(idh.id,idh);
                     }
                     
                     else if(idh.id==asrs.DHStatus_Update_IDH_ID__c && idh.Data_Type__c==UtilityConstant.VLAN && asrs.Status_Record_Type__c==UtilityConstant.FO)
                     {
                         idh.Firm_Order_Sent_EVC_PON__c=asrs.Update_Date_Time__c;
                         IDHMap.put(idh.id,idh);
                     }
                     else if(idh.id==asrs.DHStatus_Update_IDH_ID__c && idh.Data_Type__c==UtilityConstant.VLAN && asrs.Status_Record_Type__c==UtilityConstant.FA)
                     {
                         idh.Firm_Order_Accepted_EVC_PON__c=asrs.Update_Date_Time__c;
                         IDHMap.put(idh.id,idh);
                     }
                      else if(idh.id==asrs.DHStatus_Update_IDH_ID__c && idh.Data_Type__c==UtilityConstant.VLAN && asrs.Status_Record_Type__c==UtilityConstant.FC)
                     {
                         idh.FOC_Received_Date_EVC_PON__c=asrs.Update_Date_Time__c;
                         IDHMap.put(idh.id,idh);
                     } 
                     else if(idh.id==asrs.DHStatus_Update_IDH_ID__c && idh.Data_Type__c==UtilityConstant.VLAN && asrs.Status_Record_Type__c==UtilityConstant.FJ && asrs.Jeopardy_Code__c==UtilityConstant.R84)
                     {
                         idh.R84_Date_Received_EVC_PON__c=asrs.Update_Date_Time__c;
                         IDHMap.put(idh.id,idh);
                     } 
                 }
             }
          }
          if(IDHMap.size()>0)
          {
              try
              {
                  update IDHMap.values();
              }
              Catch(Exception e)
              {
                  ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
              }
          } 
     }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }
 
  }
  /*Name:ClearDHStatusIDHFields
   * Description:
   */ 
public void clearDHStatusIDHFields(SObject[] oldObjects)
{
  try{
    List<DHStatus_Access_Service_Request_Statuse__c> deleteDHStatusASRSList=oldObjects;
    Set<String> iDHSet=new Set<String>();
    List<DHStatus_Update_IDH__c> iDHList=new List<DHStatus_Update_IDH__c>();
    Map<Id,DHStatus_Update_IDH__c> iDHMap=new Map<Id,DHStatus_Update_IDH__c>();
    for(DHStatus_Access_Service_Request_Statuse__c dhasr:DeleteDHStatusASRSList)
    {
       IDHSet.add(dhasr.DHStatus_Update_IDH_ID__c);
    }
    if(IDHSet.size()>0)
    {
     IDHList=[select Id,Firm_Order_Sent_UNI_PON__c,Data_Type__c,Firm_Order_Accepted_UNI_PON__c,FOC_Received_Date_UNI_PON__c,R84_Date_Received_UNI_PON__c,Access_in_Effect_Date__c,Firm_Order_Sent_EVC_PON__c,Firm_Order_Accepted_EVC_PON__c,FOC_Received_Date_EVC_PON__c,R84_Date_Received_EVC_PON__c from DHStatus_Update_IDH__c WHERE Id IN:IDHSet];      
    }
    if(IDHList.size()>0)
    {
        for(DHStatus_Update_IDH__c idh:IDHList)
        {
            for(DHStatus_Access_Service_Request_Statuse__c asrs:DeleteDHStatusASRSList)
            {
                if(idh.id==asrs.DHStatus_Update_IDH_ID__c && idh.Data_Type__c==UtilityConstant.PORT && asrs.Status_Record_Type__c==UtilityConstant.FO)
                     {
                        idh.Firm_Order_Sent_UNI_PON__c=NULL;
                        IDHMap.put(idh.id,idh);
                     }
                     else if(idh.id==asrs.DHStatus_Update_IDH_ID__c && idh.Data_Type__c==UtilityConstant.PORT && asrs.Status_Record_Type__c==UtilityConstant.FA)
                     {
                         idh.Firm_Order_Accepted_UNI_PON__c=NULL;
                         IDHMap.put(idh.id,idh);
                     }
                     else if(idh.id==asrs.DHStatus_Update_IDH_ID__c && idh.Data_Type__c==UtilityConstant.PORT && asrs.Status_Record_Type__c==UtilityConstant.FC)
                     {
                         idh.FOC_Received_Date_UNI_PON__c=NULL;
                         IDHMap.put(idh.id,idh);
                     }
                     else if(idh.id==asrs.DHStatus_Update_IDH_ID__c && idh.Data_Type__c==UtilityConstant.PORT && asrs.Status_Record_Type__c==UtilityConstant.FJ &&  asrs.Jeopardy_Code__c==UtilityConstant.R84)
                     {
                         idh.R84_Date_Received_UNI_PON__c=NULL;
                         IDHMap.put(idh.id,idh);
                     }
                     else if(idh.id==asrs.DHStatus_Update_IDH_ID__c && idh.Data_Type__c==UtilityConstant.PORT && asrs.Status_Record_Type__c==UtilityConstant.ZI)
                     {
                         idh.Access_in_Effect_Date__c=NULL;
                         IDHMap.put(idh.id,idh);
                     }
                     
                     else if(idh.id==asrs.DHStatus_Update_IDH_ID__c && idh.Data_Type__c==UtilityConstant.VLAN && asrs.Status_Record_Type__c==UtilityConstant.FO)
                     {
                         idh.Firm_Order_Sent_EVC_PON__c=NULL;
                         IDHMap.put(idh.id,idh);
                     }
                     else if(idh.id==asrs.DHStatus_Update_IDH_ID__c && idh.Data_Type__c==UtilityConstant.VLAN && asrs.Status_Record_Type__c==UtilityConstant.FA)
                     {
                         idh.Firm_Order_Accepted_EVC_PON__c=NULL;
                         IDHMap.put(idh.id,idh);
                     }
                      else if(idh.id==asrs.DHStatus_Update_IDH_ID__c && idh.Data_Type__c==UtilityConstant.VLAN && asrs.Status_Record_Type__c==UtilityConstant.FC)
                     {
                         idh.FOC_Received_Date_EVC_PON__c=NULL;
                         IDHMap.put(idh.id,idh);
                     } 
                     else if(idh.id==asrs.DHStatus_Update_IDH_ID__c && idh.Data_Type__c==UtilityConstant.VLAN && asrs.Status_Record_Type__c==UtilityConstant.FJ && asrs.Jeopardy_Code__c==UtilityConstant.R84)
                     {
                         idh.R84_Date_Received_EVC_PON__c=NULL;
                         IDHMap.put(idh.id,idh);
                     } 
                 }
            }
        }
        if(IDHMap.size()>0)
        {
            try
            {
                update IDHMap.values();
            }
            Catch(Exception e)
            {
             ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));   
            }
        } 
      }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }
    
    }      
/*Name:updateFOCDateChangedOnIDH
 * Description:
 */ 
 public void updateFOCDateChangedOnIDH(SObject[] newObjects)
 { 
    try{
         List<DHStatus_Access_Service_Request_Statuse__c> dHStatusASRSList=newObjects;
         Set<String> iDHIDSet=new Set<String>();
         List<DHStatus_Update_IDH__c> iDHList=new List<DHStatus_Update_IDH__c>();
         Map<Id,DHStatus_Update_IDH__c> iDHMap=new  Map<Id,DHStatus_Update_IDH__c>();
         for(DHStatus_Access_Service_Request_Statuse__c asrs:DHStatusASRSList)
         {
         if(asrs.Status_Record_Type__c!=NULL && asrs.Status_Record_Type__c==UtilityConstant.FC)
         {
             IDHIDSet.add(asrs.DHStatus_Update_IDH_ID__c);
         }
         }
         if(IDHIDSet.size()>0)
         {
           IDHList=[select Id,Data_Type__c,FOC_date_Changed__c,FOC_Date_Changed_EVC_PON__c from DHStatus_Update_IDH__c WHERE Id IN:IDHIDSet];  
         }
         if(IDHList.size()>0)
         {
            for(DHStatus_Update_IDH__c idh:IDHList)
            {
                for(DHStatus_Access_Service_Request_Statuse__c asrs:DHStatusASRSList)
                {
                    if(idh.Id==asrs.DHStatus_Update_IDH_ID__c && idh.Data_Type__c==UtilityConstant.PORT && (idh.FOC_date_Changed__c==NULL || idh.FOC_date_Changed__c==SpecialCharacterConstant.CONCAT))
                    {
                        idh.FOC_date_Changed__c=UtilityConstant.NO;
                        IDHMap.put(idh.Id,idh);
                    }
                    else if(idh.Id==asrs.DHStatus_Update_IDH_ID__c && idh.Data_Type__c==UtilityConstant.PORT && idh.FOC_date_Changed__c==UtilityConstant.NO)
                    {
                        idh.FOC_date_Changed__c=UtilityConstant.YES;
                        IDHMap.put(idh.Id,idh);
                    }
                    else if(idh.Id==asrs.DHStatus_Update_IDH_ID__c && idh.Data_Type__c==UtilityConstant.PORT && idh.FOC_date_Changed__c==UtilityConstant.YES)
                    {
                        break;
                        //idh.FOC_date_Changed__c=UtilityConstant.YES;
                        //IDHMap.add(idh.Id,idh);
                    }
                    else if(idh.Id==asrs.DHStatus_Update_IDH_ID__c && idh.Data_Type__c==UtilityConstant.VLAN && (idh.FOC_Date_Changed_EVC_PON__c==NULL || idh.FOC_Date_Changed_EVC_PON__c==SpecialCharacterConstant.CONCAT))
                    {
                        idh.FOC_Date_Changed_EVC_PON__c=UtilityConstant.NO;
                        IDHMap.put(idh.Id,idh);
                    }
                    else if(idh.Id==asrs.DHStatus_Update_IDH_ID__c && idh.Data_Type__c==UtilityConstant.VLAN && idh.FOC_Date_Changed_EVC_PON__c==UtilityConstant.NO)
                    {
                        idh.FOC_Date_Changed_EVC_PON__c=UtilityConstant.YES;
                        IDHMap.put(idh.Id,idh);
                    }
                     else if(idh.Id==asrs.DHStatus_Update_IDH_ID__c && idh.Data_Type__c==UtilityConstant.VLAN && idh.FOC_Date_Changed_EVC_PON__c==UtilityConstant.YES)
                    {
                        break;
                        //idh.FOC_Date_Changed_EVC_PON__c=UtilityConstant.YES;
                        //IDHMap.add(idh.Id,idh);
                    }
                }
            }                                 
         }
        if(IDHMap.size()>0)
        {
            try
            {
                update IDHMap.values();
            }
            Catch(Exception e)
            {
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
        } 
    }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }
    
 }
 /*Name:ClearFOCDateChangedOnIDH
  * Description:
  */ 
 public void clearFOCDateChangedOnIDH(SObject[] oldObjects)
   {
    try{ 
        List<DHStatus_Access_Service_Request_Statuse__c> deleteDHStatusASRSList=oldObjects;
        Set<String> iDHIDSet=new Set<String>();
        List<DHStatus_Update_IDH__c> iDHList=new List<DHStatus_Update_IDH__c>();
        List<DHStatus_Access_Service_Request_Statuse__c> dHAccessSRSList=new List<DHStatus_Access_Service_Request_Statuse__c>();
        Map<Id,DHStatus_Update_IDH__c> iDHMap=new  Map<Id,DHStatus_Update_IDH__c>();
        for(DHStatus_Access_Service_Request_Statuse__c asrs:DeleteDHStatusASRSList)
         {
         if(asrs.Status_Record_Type__c!=NULL && asrs.Status_Record_Type__c==UtilityConstant.FC)
         {
             IDHIDSet.add(asrs.DHStatus_Update_IDH_ID__c);
         }
         }
         if(IDHIDSet.size()>0)
         {
         IDHList=[select Id,Data_Type__c,FOC_date_Changed__c,FOC_Date_Changed_EVC_PON__c from DHStatus_Update_IDH__c WHERE Id IN:IDHIDSet];
         DHAccessSRSList=[select Id,DHStatus_Update_IDH_ID__c,Status_Record_Type__c from DHStatus_Access_Service_Request_Statuse__c WHERE DHStatus_Update_IDH_ID__c IN:IDHIDSet AND Status_Record_Type__c='FC'];
         } 
        if(IDHList.size()>0)
        {
            if(DHAccessSRSList.size()==0)
            {
                for(DHStatus_Update_IDH__c idh:IDHList)
                {
                    for(DHStatus_Access_Service_Request_Statuse__c asrs:DeleteDHStatusASRSList)
                    {
                        if(idh.id==asrs.DHStatus_Update_IDH_ID__c && idh.Data_Type__c==UtilityConstant.PORT)
                        {
                            idh.FOC_date_Changed__c=NULL;
                            IDHMap.put(idh.Id,idh);
                        }
                        else if(idh.id==asrs.DHStatus_Update_IDH_ID__c && idh.Data_Type__c==UtilityConstant.VLAN)
                        {
                            idh.FOC_Date_Changed_EVC_PON__c=NULL;
                            IDHMap.put(idh.Id,idh);
                        }
                    }
                }
            }
           else if(DHAccessSRSList.size()==1)
           {
              for(DHStatus_Update_IDH__c idh:IDHList)
                {
                    for(DHStatus_Access_Service_Request_Statuse__c asrs:DeleteDHStatusASRSList)
                    {
                        if(idh.id==asrs.DHStatus_Update_IDH_ID__c && idh.Data_Type__c==UtilityConstant.PORT)
                        {
                            idh.FOC_date_Changed__c=UtilityConstant.NO;
                            IDHMap.put(idh.Id,idh);
                        }
                        else if(idh.id==asrs.DHStatus_Update_IDH_ID__c && idh.Data_Type__c==UtilityConstant.VLAN)
                        {
                            idh.FOC_Date_Changed_EVC_PON__c=UtilityConstant.NO;
                            IDHMap.put(idh.Id,idh);
                        }
                    }
                } 
           }
         else if(DHAccessSRSList.size()>1)
         {
             for(DHStatus_Update_IDH__c idh:IDHList)
                {
                    for(DHStatus_Access_Service_Request_Statuse__c asrs:DeleteDHStatusASRSList)
                    {
                        if(idh.id==asrs.DHStatus_Update_IDH_ID__c && idh.Data_Type__c==UtilityConstant.PORT)
                        {
                            idh.FOC_date_Changed__c=UtilityConstant.YES;
                            IDHMap.put(idh.Id,idh);
                        }
                        else if(idh.id==asrs.DHStatus_Update_IDH_ID__c && idh.Data_Type__c==UtilityConstant.VLAN)
                        {
                            idh.FOC_Date_Changed_EVC_PON__c=UtilityConstant.YES;
                            IDHMap.put(idh.Id,idh);
                        }
                    }
                } 
         }   
        }
        if(IDHMap.size()>0)
        {
            try
            {
                update IDHMap.values();
            }
            Catch(Exception e)
            {
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
        } 
    }catch(Exception ex){
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }
        
  }   
}