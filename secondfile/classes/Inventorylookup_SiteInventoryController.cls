/************************************************************************************** 
 Apex Class Name     : Inventorylookup_SiteInventoryController 
 Version             : 1.0 
 Created Date        : 7/10/2015 10:08 PM
 Function            : 
* Developer          : Nidhin Varghese    

*************************************************************************************/
global with sharing class Inventorylookup_SiteInventoryController{
    
    private static String searchText = SpecialCharacterConstant.CONCAT;
    public boolean displayPopup {get; set;}
    public static List<RDS_Premise_Details__c> rdsPremiseList{get; set;}
    public String customerName {get; set;}
    public String subAccNo {get; set;}
    public String conEndDate {get; set;}
    public String productName {get; set;}
    public boolean IsDealHashCreationSuccess{get; set;}
    public boolean userBeginQuote{get; set;}
    public boolean isManualFlagload{get;set;}
    public Admin_Control__c adminCtrl;
    public boolean enableAddSitesOption {get;set;}
    public String DealStatus{get;set;}
    public boolean contractRenewalCIflag{get;set;}
    public boolean contractRenewalEnable{get;set;}
    public boolean IsContractExpired{get;set;}
    public String contractRenewalStage{get;set;} 
    public boolean IsAllSiteActive{get;set;} 
    public String ContractActionTooltip {get;set;} 
    
/* 
 Name: Inventorylookup_SiteInventoryController
 Description: 
 */ 
    public Inventorylookup_SiteInventoryController(){
        String subAccNo = ApexPages.CurrentPage().getParameters().get('id');
        User userObj = [select id, Begin_Quote__c from User where id = :UserInfo.getUserId()];
        userBeginQuote = userObj.Begin_Quote__c;
        if(subAccNo != null){
            Deal_Hash__c deal = [select id,End_Customer_Name__c,Sub_Account_Number__c,ContractEndDate__c,ServiceType__c,
                                 IsDealHashCreationSuccess__c,Contract_Renewal_Status__c,Contract_Renewal_Stage__c,IsEligibleForContract__c,Contract_Action_Tooltips__c,Contract_Renewal_Lock__c,Opportunity__r.Account_Contract_Renewal__c,ManualFlow__c
                                 from Deal_Hash__c where Sub_Account_Number__c =: subAccNo Limit 1]; 

                                
            List<Opportunity> opptyList=[select Id from Opportunity where RDS_Deal_Hash__c=:deal.id and ManualFlow__c=true];       
                    isManualFlagload=false;     
                    if(opptyList.size()>0){     
                     isManualFlagload=true;         
                     }                               
            customerName = deal.End_Customer_Name__c;
            this.subAccNo = deal.Sub_Account_Number__c;
            conEndDate = deal.ContractEndDate__c;
            IsDealHashCreationSuccess = deal.IsDealHashCreationSuccess__c;         
            DealStatus = deal.Contract_Renewal_Status__c;
            ContractActionTooltip = deal.Contract_Action_Tooltips__c;
            IsAllSiteActive = deal.IsEligibleForContract__c;
            contractRenewalStage = deal.Contract_Renewal_Stage__c;           
            contractRenewalCIflag  = deal.Opportunity__r.Account_Contract_Renewal__c ;
            contractRenewalEnable = (DealStatus =='Expired' && deal.IsEligibleForContract__c && contractRenewalStage == Null && !deal.Contract_Renewal_Lock__c) ? true : false;
            //IsContractExpired = (DealStatus =='Expired')? true : false;
            if(contractRenewalStage == 'Renewal Request Pending'){
                IsContractExpired = true;
            }else if(DealStatus =='Expired'){
                IsContractExpired = true;
            }else{
                IsContractExpired = false;
            }   
                  
            if(deal.ServiceType__c.equals(MACDConstant.MIS))
                productName = MACDConstant.ATT_MANAGED_INTERNET_SERVICE;
            else if(deal.ServiceType__c.equals(MACDConstant.AVPN))
                productName = MACDConstant.ATT_VIRTUAL_PRIVATE_NETWORK_SERVICE;
        }
      adminCtrl = new Admin_Control__c();
    adminCtrl = [Select Id, MIS_Add_Sites_Suppression__c from Admin_Control__c LIMIT 1];
    enableAddSitesOption = adminCtrl.MIS_Add_Sites_Suppression__c;        
    }
    
        
    /*
    * Class name   : closePopup
    * Description  : Method to close the delete popup
    * Parameter    : N/A 
    * Return Type  : N/A
    */    
/* 
 Name: closePopup
 Description: 
 */ 
    public void closePopup() {
    try{        
        displayPopup = false; 
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }       
    } 
    
    /*
    * Class name   : showPopup
    * Description  : Method to open the delete popup
    * Parameter    : N/A 
    * Return Type  : N/A
    */       
/* 
 Name: showPopup
 Description: 
 */ 
    public void showPopup() {
    try{        
            displayPopup = true; 
            }catch(Exception e){
        ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
    }   
        
    } 
    
    /*Defines shape of JSON response*/
    global class Response {
        public Integer sEcho;
        public List<RDS_Premise_Details__c> aaData;
        public Integer iTotalRecords;
        public Integer iTotalDisplayRecords;
        public map<id,list<boolean>> mapMacdOptions;
        /*Response*/
        Response(Integer echo,Integer total,List<RDS_Premise_Details__c> premiseList) {
            this.sEcho = echo;
            this.aaData = premiseList;
            this.iTotalRecords = total;
            this.iTotalDisplayRecords = total;
            
            List<RDS_Premise_Details__c>  lstPremise= [select id,notification_status__c,CNR_Billing__c,Current_Version__c,VLAN_Count__c,Unilink__c,Site_Status__c,MACD_Type__c,Service_Type__c,Combined_VLAN_Speed__c,Transport_Type__c,Port_Speed__c, Access_Region__c,Class_of_Service__c,DealHash__r.Contract_Renewal_Status__c,(select id,
                     Hi_Cap_Flex_Minimum_Bandwidth_Commitment__c from Circuit_and_VLAN_Details__r),
                     DealHash__r.Opportunity__r.Account.Enable_feature_ADD_VLAN__c,
                              DealHash__r.Opportunity__r.Account.Enable_feature_Cancel_InFlight__c,
                              DealHash__r.Opportunity__r.Account.Enable_feature_Change_COS__c,
                              DealHash__r.Opportunity__r.Account.Enable_feature_Change_Speed_Access_Port__c,
                              DealHash__r.Opportunity__r.Account.Enable_feature_UBB_Add__c,
                              DealHash__r.Opportunity__r.Account.Enable_feature_UBB_Change__c,
                              DealHash__r.Opportunity__r.Account.Enable_feature_UBB_Remove__c,
                              DealHash__r.Opportunity__r.Account.Enable_feature_VLAN_Disconnect__c,
                              DealHash__r.Opportunity__r.Account.Enable_feature_Change_VLAN_speed__c,
                              DealHash__r.Opportunity__r.Account.Enable_feature_Add_COS__c,
                              DealHash__r.Opportunity__r.Account.Enable_feature_Remove_COS__c
                     from RDS_Premise_Details__c where id in : premiselist];
            this.mapMacdOptions=prepareMapMacdOptions(lstPremise); 
        }
        
        /*
     added by sudhakar
     */
    /*public void UpdateJsonMapMacdOptions(list<RDS_Premise_Details__c> premiseList)
    {
        map<id,boolean[]> mapMacdOptions=prepareMapMacdOptions(premiseList);
        JsonMapMacdOptions=JSON.serialize(mapMacdOptions); 
    } */
        
        
/* 
 Name: prepareMapMacdOptions
 Description: 
 */ 
        public map<id,list<boolean>> prepareMapMacdOptions(list<RDS_Premise_Details__c> premiseList){
           try{
           map<id,list<boolean>> mapMacdOptions=new map<id,list<boolean>>();
           
           for(RDS_Premise_Details__c premise:premiseList){
               list<boolean> options=new list<boolean>();
                  options.add(true);
                  options.add(IsEligibleforVLANAdd(premise) && IsEligibleforManual(premise));
                  options.add(IsEligibleforVLANdisconnect(premise) && IsEligibleforManual(premise));
                  options.add(IsEligibleforUbbAdd(premise) && IsEligibleforManual(premise));
                  options.add(IsEligibleforUbbChange(premise) && IsEligibleforManual(premise));
                  options.add(IsEligibleforUbbRemove(premise) && IsEligibleforManual(premise));
                  options.add(IsEligibleforUbbChangeAccessPort(premise) && IsEligibleforManual(premise));
                  options.add(IsEligibleforInflight(premise) && IsEligibleforManual(premise));
                  options.add(IsEligibleforChangeClassofServiceProfileID(premise) && IsEligibleforManual(premise));  //IsEligibleforChangeClassofServiceProfileID(premise));
                  options.add(IsEligibleforVlanSpeedChange(premise) && IsEligibleforManual(premise));
                  options.add(IsEligibleforAddCoS(premise) && IsEligibleforManual(premise));
                  options.add(IsEligibleforRemoveCoS(premise) && IsEligibleforManual(premise));
                  options.add(false);
                  
               mapMacdOptions.put(premise.id,options); 
            }
                return mapMacdOptions;
           }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            return null;
            }
       }
       
       
       /* 
 Name: IsEligibleforManual
 Description:Logic for checking Manual flag  
 */      
        Public boolean isEligibleforManual(RDS_Premise_Details__c premise)                   
                {
                try{        
                        
                 List<Opportunity> opptyList=[select Id from Opportunity where RDS_Deal_Hash__c =:premise.DealHash__c and ManualFlow__c=true];      
                            
                    if(opptyList.size()>0 || premise.DealHash__r.Contract_Renewal_Status__c == 'Expired'){     
                     return false;          
                                
                     } else{        
                            
                     return true;           
                     }          
                }catch(Exception e){
                    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                    return null;
            }
                                                                
          }      
          
       
             /* 
 Name: IsEligibleforVLANAdd
 Description:Disable or Enable the ADD VLAN Option
 */  
       Public boolean isEligibleforVLANAdd(RDS_Premise_Details__c premise){
    try{
        if((premise.Current_Version__c==true) && (premise.notification_status__c==Null || premise.notification_status__c==MACDConstant.UPDATECOMPLETE) && (premise.Site_Status__c ==MACDConstant.ACTIVE) && (premise.Service_Type__c == MACDConstant.AVPN) && (premise.Transport_Type__c == MACDConstant.SWITCHEDETHERNET) && (premise.VLAN_Count__c<12) && decimal.ValueOf(premise.Port_Speed__c).SetScale(2)  > ResetNulls(premise.Combined_VLAN_Speed__c) &&(premise.DealHash__r.Opportunity__r.Account.Enable_feature_ADD_VLAN__c== true)){
                 return true;
        
            } else {
                   return false;
                 }
                 }catch(Exception e){
                    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                    return null;
            }
                
     }
              
     
     /* 
 Name: IsEligibleforVLANAdd
 Description:Disable or Enable the Disconnect VLAN Option
 */    
       Public boolean isEligibleforVLANdisconnect(RDS_Premise_Details__c premise){ 
       try{
          if((premise.Current_Version__c==true) && (premise.notification_status__c==Null || premise.notification_status__c==MACDConstant.UPDATECOMPLETE) &&(premise.Site_Status__c ==MACDConstant.ACTIVE) &&(premise.VLAN_Count__c>=3) && (premise.DealHash__r.Opportunity__r.Account.Enable_feature_VLAN_Disconnect__c== true)){
              
               return true;
           }
         else
             return false;
         }catch(Exception e){
                    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                    return null;
            }
     }
       
  /* 
 Name: IsEligibleforUbbAdd
 Description:
 */       
    Public boolean isEligibleforUbbAdd(RDS_Premise_Details__c premise){
        try{
         string HiCapMBC=premise.Circuit_and_VLAN_Details__r[0].Hi_Cap_Flex_Minimum_Bandwidth_Commitment__c;
         if(((premise.Service_Type__c ==MACDConstant.AVPN) || (premise.Service_Type__c ==MACDConstant.MIS)) &&(premise.Transport_Type__c == MACDConstant.SWITCHEDETHERNET) && (premise.notification_status__c==Null || premise.notification_status__c==MACDConstant.UPDATECOMPLETE) && (premise.Access_Region__c == MACDConstant.Y)&& (premise.Current_Version__c==true) && (premise.Site_Status__c ==MACDConstant.ACTIVE) && (premise.MACD_Type__c !=MACDConstant.D ) && (premise.DealHash__r.Opportunity__r.Account.Enable_feature_UBB_Add__c== true)){
               if((Integer.valueof(correctNulls(premise.Port_Speed__c))>10)  && (HiCapMBC==SpecialCharacterConstant.CONCAT||HiCapMBC==null)){
                       return true;
                   }
               else
                       return false;
           }
         else
             return false;
         }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                return null;
            }
    }  
 /* 
 Name: IsEligibleforUbbChange
 Description:
 */   
  Public boolean isEligibleforUbbChange(RDS_Premise_Details__c premise){
      try{
        string HiCapMBC=premise.Circuit_and_VLAN_Details__r[0].Hi_Cap_Flex_Minimum_Bandwidth_Commitment__c; 
         if(((premise.Service_Type__c ==MACDConstant.AVPN) || (premise.Service_Type__c ==MACDConstant.MIS)) &&(premise.Transport_Type__c == MACDConstant.SWITCHEDETHERNET) && (premise.notification_status__c==Null || premise.notification_status__c==MACDConstant.UPDATECOMPLETE) && (premise.Access_Region__c == MACDConstant.Y)&&(premise.Current_Version__c==true) && (premise.Site_Status__c ==MACDConstant.ACTIVE) && (premise.MACD_Type__c !=MACDConstant.D) && (premise.DealHash__r.Opportunity__r.Account.Enable_feature_UBB_Change__c== true)){
               if((Integer.valueof(correctNulls(premise.Port_Speed__c))>10)  && (HiCapMBC != SpecialCharacterConstant.CONCAT&&HiCapMBC!=null)){
                      return true;
                   }
                   else
                       return false;
           }
         else
             return false;
         }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            return null;
        }   
     }
 /* 
 Name: IsEligibleforUbbRemove
 Description:
 */      
     Public boolean isEligibleforUbbRemove(RDS_Premise_Details__c premise){
         try{
        string HiCapMBC=premise.Circuit_and_VLAN_Details__r[0].Hi_Cap_Flex_Minimum_Bandwidth_Commitment__c;
         if(((premise.Service_Type__c ==MACDConstant.AVPN) || (premise.Service_Type__c ==MACDConstant.MIS)) &&(premise.Transport_Type__c == MACDConstant.SWITCHEDETHERNET) && (premise.notification_status__c==Null || premise.notification_status__c==MACDConstant.UPDATECOMPLETE) && (premise.Access_Region__c == MACDConstant.Y)&& (premise.Current_Version__c==true) && (premise.Site_Status__c ==MACDConstant.ACTIVE) && (premise.MACD_Type__c !=MACDConstant.D ) && (premise.DealHash__r.Opportunity__r.Account.Enable_feature_UBB_Remove__c== true)){
               if(HiCapMBC!=SpecialCharacterConstant.CONCAT && HiCapMBC!=null){
                      return true;
                   }
                   else
                       return false;
           }
         else
             return false;
                 }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            return null;
        }   
     }
     
     
     /* 
 Name: IsEligibleforUbbChangeAccessPort
 Description:Change/Speed Access Port
 */
     Public boolean isEligibleforUbbChangeAccessPort(RDS_Premise_Details__c premise){ 
     try{
          if(((premise.Current_Version__c==true) && (premise.Site_Status__c ==MACDConstant.ACTIVE)) && (premise.notification_status__c==Null || premise.notification_status__c==MACDConstant.UPDATECOMPLETE) &&(premise.DealHash__r.Opportunity__r.Account.Enable_feature_Change_Speed_Access_Port__c== true)){
              
               return true;
           }
         else
             return false;
             }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            return null;
        }   
     }
     /* 
 Name: IsEligibleforVlanSpeedChange
 Description:
 */
     Public boolean isEligibleforVlanSpeedChange(RDS_Premise_Details__c premise)
     {
         try{
      if((premise.Current_Version__c==true) && (premise.Site_Status__c ==MACDConstant.ACTIVE) && (premise.notification_status__c==Null || premise.notification_status__c==MACDConstant.UPDATECOMPLETE) && (premise.Service_Type__c == MACDConstant.AVPN) && (premise.Unilink__c== SpecialCharacterConstant.TRUE_LITERAL) && (premise.DealHash__r.Opportunity__r.Account.Enable_feature_Change_VLAN_speed__c))
           {
             return true;
           }   
            else
            {
                   return false;
             }  
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            return null;
        }                
                
     }  
     
     
     /* 
 Name:IsEligibleforChangeClassofServiceProfileID
 Description:Change Class Of Service
 */
     Public boolean isEligibleforChangeClassofServiceProfileID(RDS_Premise_Details__c premise){  
try{     
         if((premise.Current_Version__c==true) && (premise.Site_Status__c ==MACDConstant.ACTIVE) && (premise.Class_of_Service__c==true) && (premise.notification_status__c==Null || premise.notification_status__c==MACDConstant.UPDATECOMPLETE) && (premise.DealHash__r.Opportunity__r.Account.Enable_feature_Change_COS__c== true)){              
                      return true;
                   }
                   else
                       return false;
                    }catch(Exception e){
                    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                    return null;
                }   
           }
     
 /* 
 Name:IsEligibleforInflight
 Description:
 */    
     Public boolean isEligibleforInflight(RDS_Premise_Details__c premise)
         {
             try{
             if((premise.Site_Status__c==MACDConstant.NEW1 || premise.Site_Status__c==MACDConstant.PENDING1 || premise.Site_Status__c ==SpecialCharacterConstant.CONCAT || premise.Site_Status__c == NULL)&& (premise.notification_status__c==Null || premise.notification_status__c==MACDConstant.UPDATECOMPLETE) && premise.Current_Version__c==TRUE && (premise.DealHash__r.Opportunity__r.Account.Enable_feature_Cancel_InFlight__c== true)&& premise.CNR_Billing__c == false)
             {
                 return true;
             }
             else
             {
                 return false;
             }
         }catch(Exception e){
    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
    return null;
}   
         }
     /* 
 Name:IsEligibleforAddCoS
 Description:
 */ 
         Public boolean isEligibleforAddCoS(RDS_Premise_Details__c premise)             
            {
try{                
            if((premise.Current_Version__c==true) && (premise.notification_status__c==Null || premise.notification_status__c==MACDConstant.UPDATECOMPLETE) && (premise.Site_Status__c ==MACDConstant.ACTIVE) && (premise.Class_of_Service__c==false) && (premise.DealHash__r.Opportunity__r.Account.Enable_feature_Add_COS__c == true))           
               {                        
                 return true;                           
              }         
            else        
                {       
                 return false;      
                }           
              } catch(Exception e){
    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
    return null;
}                                        
            }    
/* 
 Name: correctNulls
 Description: 
 */ 
/* 
 Name: correctNulls
 Description: 
 */ 
      public string correctNulls(string speedval){
          try{
        if(speedval==null || speedval==SpecialCharacterConstant.CONCAT){
            
                
            
            return '0';
                }else{
                    return speedval;
                }
          }catch(Exception e){
    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
    return null;
}                  
    }
    
        
    /* 
 Name:IsEligibleforRemoveCoS
 Description:Remove Class Of Service
 */    
     Public boolean isEligibleforRemoveCoS(RDS_Premise_Details__c premise){ 
try{     
             if((premise.Current_Version__c==true) && (premise.notification_status__c==Null || premise.notification_status__c== MACDConstant.UPDATECOMPLETE) && (premise.Site_Status__c == MACDConstant.ACTIVE) && (premise.Class_of_Service__c==true) && (premise.DealHash__r.Opportunity__r.Account.Enable_feature_Remove_COS__c == true))       
                   {                    
                       return true;     
                   }        
             else       
                   {        
                       return false;        
                   }  
}catch(Exception e){
    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
    return null;
}                              
           }       
        
     //Reset the null values to proper formats   
/* 
 Name: ResetNulls
 Description: 
 */ 
/* 
 Name: ResetNulls
 Description: 
 */ 
      public decimal resetNulls(decimal totalSpeed  ){
          try{
          
      return (totalSpeed == null)? 0.00 : totalSpeed ;
    }catch(Exception e){
    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
    return null;
}   
  
   }
    }
    
    @RemoteAction
    /*fetchPremiseAndCircuitVlanRecords*/
    global static Response fetchPremiseAndCircuitVlanRecords(List<Map<String, Object>> request, String subAccNo) {
        Response res = null;
           String whereClauseText = SpecialCharacterBuyFlowConstant.CONCAT;
        
        List<Circuit_and_VLAN_Details__c> cvdsT1 = new List<Circuit_and_VLAN_Details__c>();  
        List<Circuit_and_VLAN_Details__c> cvdsNT1 = new List<Circuit_and_VLAN_Details__c>();
        List<RDS_Premise_Details__c> tempRDSPList = new List<RDS_Premise_Details__c>();
        RDS_Premise_Details__c tempRDSP = new RDS_Premise_Details__c();
        //String subAccNo = ApexPages.CurrentPage().getParameters().get('id');
       
        if(subAccNo != null){
            List<Deal_Hash__c> dealList = [select id from Deal_Hash__c where Sub_Account_Number__c =: subAccNo];
            List<RDS_Premise_Details__c> rdpdsT1 = [select id,(select id from Circuit_and_VLAN_Details__r)
                                                    from RDS_Premise_Details__c where DealHash__r.id In : dealList
                                                    and Current_Version__c = true 
                                                    and (Site_Status__c != 'HARD_DISCONNECT' And Site_Status__c != 'CANCELLED')
                                                    and (Transport_Type__c = 'T1' or Transport_Type__c = 'SwitchedEthernet')];
            
            List<RDS_Premise_Details__c> rdpdsNT1 = [select id,(select id from Circuit_and_VLAN_Details__r)
                                                     from RDS_Premise_Details__c where DealHash__r.id In : dealList
                                                     and Current_Version__c = true 
                                                     and (Site_Status__c != 'HARD_DISCONNECT' And Site_Status__c != 'CANCELLED')
                                                     and Transport_Type__c = 'nT1'];
            
            if(rdpdsT1 != null && !rdpdsT1.isEmpty()){
                cvdsT1 = [select id,Premise__r.id, Premise__r.isAlreadyUpdated__c,(select id,Access_Circuit_ID__c from Circuit_and_VLAN_Details__r where circuitStatus__c != 'Pending_Delete' And circuitStatus__c != 'Deleted')
                          from Circuit_and_VLAN_Details__c where Premise__r.id IN : rdpdsT1];
                for(Circuit_and_VLAN_Details__c cv : cvdsT1){
                    if(cv.Circuit_and_VLAN_Details__r != null && !(cv.Circuit_and_VLAN_Details__r).isEmpty()){
                        tempRDSP = updatePremiseDetailsWithCircuitID(cv.Circuit_and_VLAN_Details__r,cv.Premise__r.ID);
                        tempRDSPList.add(tempRDSP);
                    }
                }
            }if(rdpdsNT1 != null && !rdpdsNT1.isEmpty()){
                cvdsNT1 = [select id,Premise__r.id,Premise__r.isAlreadyUpdated__c,(select id,Access_Circuit_ID__c from Circuit_and_VLAN_Details__r where circuitStatus__c != 'Pending_Delete' And circuitStatus__c != 'Deleted')
                           from Circuit_and_VLAN_Details__c where Premise__r.id IN : rdpdsNT1];
                for(Circuit_and_VLAN_Details__c cv : cvdsNT1){
                    if(cv.Circuit_and_VLAN_Details__r != null && !(cv.Circuit_and_VLAN_Details__r).isEmpty()){
                        tempRDSP = updatePremiseDetailsWithCircuitID(cv.Circuit_and_VLAN_Details__r,cv.Premise__r.ID);
                        tempRDSPList.add(tempRDSP);
                    }
                }
            }       
            if(tempRDSPList != null && !tempRDSPList.isEmpty())
                update tempRDSPList;
            
            Params p = new Params(request);
          
            if(p.searchString != null && p.searchString != '') {
                searchText = '%'+p.searchString+'%';
                whereClauseText = 'Premise_Friendly_Name__c Like: searchText '
                    +'OR Access_Circuit_ID__c Like: searchText '
                    +'OR No_Of_Circuits__c Like: searchText '
                    +'OR SiteStatusSpecificToInventory__c Like: searchText '
                    +'OR Premise_Street_Name__c  Like: searchText '
                    +'OR Premise_City__c Like: searchText '
                    +'OR Premise_State__c Like: searchText '
                    +'OR Premise_Zipcode__c Like: searchText ';
            }
          
            String soql = ''
                + ' select ' + 'Id, '+ 'Premise_Friendly_Name__c, ' + 'Complete_Site_Address__c, ' + 'Access_Circuit_ID__c, '
                + 'SiteStatusSpecificToInventory__c, ' + ' No_Of_Circuits__c'
                + ' from RDS_Premise_Details__c where DealHash__r.id In : dealList And Current_Version__c = true '
                + ' And (Site_Status__c != \'HARD_DISCONNECT\' And Site_Status__c != \'CANCELLED\')'
                + ((whereClauseText != null && whereClauseText != '') ? ' And ('+whereClauseText+')' :'')
                + ' order by ' + String.join(orderBys(p), ', ')
                + ' limit :length'
                + ' offset :start'
                ;
            
            Integer start = p.start;
            Integer length = p.length;
            
            
            List<RDS_Premise_Details__c> prmiseDetailList = new List<RDS_Premise_Details__c>();
            if(whereClauseText == SpecialCharacterConstant.CONCAT) {
                for(RDS_Premise_Details__c prmiseDetailObj : Database.query(soql)) {
                    prmiseDetailList.add(prmiseDetailObj);
                }
                res = new Response(p.echo,[select count() from RDS_Premise_Details__c where DealHash__r.id In : dealList
                                           And Current_Version__c = true 
                                           And (Site_Status__c != 'HARD_DISCONNECT' And Site_Status__c != 'CANCELLED')
                                                limit 50000],
                                   prmiseDetailList);
            } else {
                for(RDS_Premise_Details__c prmiseDetailObj : Database.query(soql)) {
                    prmiseDetailList.add(prmiseDetailObj);
                }
                res = new Response(p.echo,[select count() from RDS_Premise_Details__c
                                           where DealHash__r.id In : dealList
                                           And (Premise_Friendly_Name__c Like: searchText 
                                                OR Access_Circuit_ID__c Like: searchText OR No_Of_Circuits__c Like: searchText 
                                                OR Site_Status__c Like: searchText OR Premise_Street_Name__c  Like: searchText 
                                                OR Premise_City__c Like: searchText OR Premise_State__c Like: searchText 
                                                OR Premise_Zipcode__c Like: searchText) And Current_Version__c = true 
                                           And (Site_Status__c != 'HARD_DISCONNECT' And Site_Status__c != 'CANCELLED')
                                           limit 50000],
                                   prmiseDetailList);
            }
            
            
        }
        
        whereClauseText = '';
        return res;
  }
    /*updatePremiseDetailsWithCircuitID*/
    private static RDS_Premise_Details__c updatePremiseDetailsWithCircuitID(List<RDS_Access_Circuit_ID__c> rdsCircuitIdList,
                                                                            ID premiseId){
        RDS_Premise_Details__c RDSP = new RDS_Premise_Details__c();
        try{
        for(RDS_Access_Circuit_ID__c ra : rdsCircuitIdList){
                if(ra.Access_Circuit_ID__c.contains('/801/')){
                    RDSP.Access_Circuit_ID__c = ra.Access_Circuit_ID__c;
                    RDSP.ID = premiseId;
                    RDSP.No_Of_Circuits__c = String.valueOf(rdsCircuitIdList.size());
                    RDSP.isAlreadyUpdated__c = true;
                    RDSP.isNotUpdatedForSiteInventory__c = false;
                    break;
                    }else if(!ra.Access_Circuit_ID__c.contains(MACDConstant.SIVARConst_802_x) &&  !ra.Access_Circuit_ID__c.contains(MACDConstant.SIVARConst_803_x)
                        &&  !ra.Access_Circuit_ID__c.contains(MACDConstant.SIVARConst_804_x) &&  !ra.Access_Circuit_ID__c.contains(MACDConstant.SIVARConst_805_x)
                        &&  !ra.Access_Circuit_ID__c.contains(MACDConstant.SIVARConst_806_x) &&  !ra.Access_Circuit_ID__c.contains(MACDConstant.SIVARConst_807_x)
                        &&  !ra.Access_Circuit_ID__c.contains(MACDConstant.SIVARConst_808_x)){
                        RDSP.Access_Circuit_ID__c = ra.Access_Circuit_ID__c;
                        RDSP.ID = premiseId;
                        RDSP.No_Of_Circuits__c = String.valueOf(rdsCircuitIdList.size());
                        RDSP.isAlreadyUpdated__c = true;
                        RDSP.isNotUpdatedForSiteInventory__c = false;
                    }
            }   
        }
    catch(Exception ex){System.debug('exception in updatePremiseDetailsWithCircuitID mtd:: '+ex);}
                return RDSP;
      
    }
    /*orderBys*/
     private static String[] orderBys(Params p) {
        Map<String, String> soqlDirections = new Map<String, String>{
            'asc' => 'asc nulls last',
                'desc' => 'desc nulls first'
                };
                    String[] orderBys = new String[] {};
                        Integer min = Math.min(p.sortColumns.size(), p.sortDirections.size());
         for (Integer i = 0; i < min; i++) {
            
             orderBys.add(''
                          + p.columns[p.sortColumns[i]]
                          + ' '
                          + soqlDirections.get(p.sortDirections[i])
                         );
             
         }
         return orderBys;
     }
    
    /* DataTable passes JSON definition of what server should do*/
    private class Params {
        Map<String, Object> m = new Map<String, Object>();
        
        Integer echo;
        Integer start;
        Integer length;
        String[] columns;
        String searchString;
        Integer[] sortColumns;
        String[] sortDirections;
        /**/
        Params(List<Map<String, Object>> request) {
            for (Map<String, Object> r : request) {
                m.put((String) r.get('name'), r.get('value'));
            }
            echo = integer(MACDConstant.SECHO);
            start = integer(MACDConstant.IDISPLAYSTART);
            length = integer(MACDConstant.IDISPLAYLENGTH);
            columns = stringArray(MACDConstant.MDATAPROP);
            sortColumns = integerArray(MACDConstant.ISORTCOL);
            sortDirections = stringArray(MACDConstant.SSORTDIR);
            searchString = m.get('searchText') != null ? (String)m.get('searchText') : '';
            
        }
        /*stringArray*/
        String[] stringArray(String prefix) {
            String[] strings = new String[] {};
                for (Object o : array(prefix)) {
                    strings.add(o != null ? esc(String.valueOf(o)) :null);
                }
            return strings;
        }
        /*integerarray*/
        Integer[] integerArray(String prefix) {
            Integer[] integers = new Integer[] {};
                for (Object o : array(prefix)) {
                    integers.add(o != null ? Integer.valueOf(o) : null);
                }
            return integers;
        }
        /*ARRAY*/
        Object[] array(String prefix) {
            Object[] objects = new Object[] {};
                for (Integer i = 0; true; i++) {
                    Object o = m.get(prefix + '_' + i);
                    if (o != null) {
                        objects.add(o);
                    } else {
                        break;
                    }
                }
            return objects;
        }
         /**/
         Integer integer(String name) {
            Object o = m.get(name); 
            if (o instanceof Decimal) {
                return ((Decimal) o).intValue();
            } else if (o instanceof Integer) {
                return (Integer) o;
            } else {
                return null;
            }
         }
        
         /* Guard against SOQL injection*/
         String esc(String s) {
             return s != null ? String.escapeSingleQuotes(s) : null;
         }
     }
}