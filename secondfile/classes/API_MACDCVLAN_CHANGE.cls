/*
     Component Name :API_MACDCVLAN_CHANGE 
     Requirement/User Story Number : US306463
     Requirement Description: Class to for cloning objects under CVLAN on MACD Change.
     Component Author:Accenture IDC
     Created Date: 27th November 2014 
     Revised : 3rd April 2015
     Version:1.0
     Last Modified By: Accenture IDC
    */
    
/* Method to create Related objects under CVLAN when MACD change is performed */ 
global class API_MACDCVLAN_CHANGE { 
@future

    /*Name:createChildRecordsForMACDCVLANCHANGE
      Decription:
    */
     public static void createChildRecordsForMACDCVLANCHANGE(Set<Id> macdCVLANIdSet, Set<Id> masterCVLANIdSet, Set<Id> valIds,Set<Id> OldpremiseSetID,Set<Id> NewPremiseSet,Set<Id> validSetId,String macdaction,Integer upgrade, String stat, Integer oldPortSpeedNum, Integer newPortSpeedNum, Integer cktCount, Boolean isEthernetAccessChange, Decimal version, String dealHashId,Boolean isInterfaceChange){
     Map<String,Circuit_and_VLAN_Details__c> macdCVLANMap = new Map<String,Circuit_and_VLAN_Details__c>();
     Map<String,Circuit_and_VLAN_Details__c> cVLANmappackage = new Map<String,Circuit_and_VLAN_Details__c>();
     List<RDS_Access_Circuit_ID__c> accCktIdList = new List<RDS_Access_Circuit_ID__c>();
     List<RDS_Access_Circuit_ID__c> accCKTToClone = new List<RDS_Access_Circuit_ID__c>();
     List<RDS_ALB_Access_Circuits__c> albIdList = new List<RDS_ALB_Access_Circuits__c>();
     List<RDS_ALB_Access_Circuits__c> albToClone = new List<RDS_ALB_Access_Circuits__c>();
     List<RDS_Access_Billing_Element_Details__c> accBillList = new List<RDS_Access_Billing_Element_Details__c>();
     List<RDS_Access_Billing_Element_Details__c> accBillToCloneList = new List<RDS_Access_Billing_Element_Details__c>();
     List<RDS_SWIP_Contacts__c> rdsSWIPCon = new List<RDS_SWIP_Contacts__c>();
     List<RDS_SWIP_Contacts__c> rdsSWIPConToClone = new List<RDS_SWIP_Contacts__c>();
     List<VLAN_Information__c> vlanList = new List<VLAN_Information__c>();
     List<VLAN_Information__c> vlanToClone = new List<VLAN_Information__c>();
     List<RDS_VPN_Data__c> vpnList = new List<RDS_VPN_Data__c>();
     List<RDS_VPN_Data__c> vpnToClone = new List<RDS_VPN_Data__c>();
     List<RDS_History_Tracking__c> histList = new List<RDS_History_Tracking__c>();
     List<RDS_History_Tracking__c> histToClone = new List<RDS_History_Tracking__c>();
     List<RDS_Mutlicast_V4__c> v4List = new List<RDS_Mutlicast_V4__c>();
     List<RDS_Mutlicast_V4__c> v4ToClone = new List<RDS_Mutlicast_V4__c>();
     List<RDS_Mutlicast_V6__c> v6List = new List<RDS_Mutlicast_V6__c>();
     List<RDS_Mutlicast_V6__c> v6ToClone = new List<RDS_Mutlicast_V6__c>();
     List<RDS_V4_Family_Data__c> v4FamLongList = new List<RDS_V4_Family_Data__c>();
     List<RDS_V4_Family_Data__c> v4FamLongListToClone = new List<RDS_V4_Family_Data__c>();
     List<RDS_V4_Family_Data__c> v4FamShortList = new List<RDS_V4_Family_Data__c>();
     List<RDS_V4_Family_Data__c> v4FamShortListToClone = new List<RDS_V4_Family_Data__c>();
     List<V6_Family_Data__c> v6FamLongList = new List<V6_Family_Data__c>();
     List<V6_Family_Data__c> v6FamLongListToClone = new List<V6_Family_Data__c>();
     List<V6_Family_Data__c> v6FamShortList = new List<V6_Family_Data__c>();
     List<V6_Family_Data__c> v6FamShortListToClone = new List<V6_Family_Data__c>();
     List<RDS_V4_LAN_IP_Address__c> v4LanList = new List<RDS_V4_LAN_IP_Address__c>();
     List<RDS_V4_LAN_IP_Address__c> v4LanListToClone = new List<RDS_V4_LAN_IP_Address__c>();
     List<RDS_V6_LAN_IP_Address__c> v6LanList = new List<RDS_V6_LAN_IP_Address__c>();
     List<RDS_V6_LAN_IP_Address__c> v6LanListToClone = new List<RDS_V6_LAN_IP_Address__c>();
     List<RDS_V4_Family_Data__c> orgV4Family = new List<RDS_V4_Family_Data__c>();
     List<V6_Family_Data__c> orgV6Family = new List<V6_Family_Data__c> ();
     List<RDS_V4_Family_Data__c> clonedV4Family = new List<RDS_V4_Family_Data__c>();
     List<V6_Family_Data__c> clonedV6Family = new List<V6_Family_Data__c>();
     Map<String,RDS_Validation_Configuration__c> validConMap = new Map<String,RDS_Validation_Configuration__c>();
     List<RDS_BillingRelatedElements__c> cloneBillList = new List<RDS_BillingRelatedElements__c>();  //List of Billing records to be cloned during MACD
     List<RDS_Contact__c> cloneConList = new List<RDS_Contact__c>();  //List of Contact records to be cloned during MACD
     List<RDS_Competitive_Discount__c> cloneCompDiscList = new List<RDS_Competitive_Discount__c>();  //List of Competitive Discount records to be cloned during MACD
     List<RDS_BillingRelatedElements__c> billList = [Select Id,PremiseDetails__r.ID,PremiseDetails__r.DealHash__r.Id, PremiseDetails__c,ChargeType__c,Charge_Element_ID__c, Billing_Premise_Number__c from RDS_BillingRelatedElements__c Where PremiseDetails__r.ID IN : OldpremiseSetID and Product_Detail__c!='installationCharge' and Product_Detail__c!='One Time Fee' ]; 
     List<RDS_Premise_Details__c> clonedPremIdList=[Select Id, RDS_Version__c,Premise_Number__c, Circuit_mlppSegments__c from RDS_Premise_Details__c Where Id IN: NewPremiseSet];
     Map<String,RDS_Premise_Details__c> premiseMap = new Map<String,RDS_Premise_Details__c>();
     Map<String,RDS_Access_Circuit_ID__c> accessCktMap = new Map<String,RDS_Access_Circuit_ID__c>();
     Map<String, Decimal> siteAmountsMap = new Map<String, Decimal>();
     Map<String, String> siteBEIDMap = new Map<String, String>();
     Map<String,COS_Value__c> cosmaps = new Map<String,COS_Value__c>();
     Decimal circuitCount =1;
     Decimal accessAmount =0;
     Integer existingCktCount = 0;
     Set<String> premiseNumberSet = new Set<String>();
     List<RDS_Validation__c> validationlists = new List<RDS_Validation__c>(); 
     Map<String,RDS_Validation__c> validationMap = new Map<String,RDS_Validation__c>(); 
     Map<String,List<RDS_Access_Circuit_ID__c>> premCktMap = new Map<String,List<RDS_Access_Circuit_ID__c>>();
     Opportunity latetestOppty;
     Id acktRefId;
     String acktRefPremiseNum;
     String acktIdString;
     List<RDS_BillingRelatedElements__c> accBillListtodelete = new list<RDS_BillingRelatedElements__c>();
     String mastergroupid;
     String masterLAInumber;
     /**************************************** Billing Related Element Cloning Block**********************************************/
     if(billList.size()>0 && clonedPremIdList.size()>0){
           set<String> clonedPremiseNumberSet= new Set<string>();
           for(RDS_Premise_Details__c premiseDetails: clonedPremIdList)
           {
            clonedPremiseNumberSet.add(premiseDetails.Premise_Number__c); 
           }
       
           List<Product_Pricing__c> billingPortHistorylist= New List<Product_Pricing__c>();
           RDS_Validation__c rdval;
           Apttus_Proposal__Proposal__c relatedquote;
           
           List<RDS_Validation__c> validationList=[select id,Premise_Number__c,Transport_type__c,Port_Speed__c,MACD_Change_Type__c,Related_quote__c,Class_of_Service__c,Unilink__c from RDS_Validation__c where id IN : validSetId] ;
                  
           if(macdaction== MACDConstant.PORTALMACD)
                {
            
                if(validSetId!=null){
                    rdval = [select id,MACD_Change_Type__c, Related_quote__c from RDS_Validation__c where id IN : validSetId and Related_quote__c!=null];
                    relatedquote = [select id,Apttus_Proposal__Opportunity__r.Id from Apttus_Proposal__Proposal__c where id=:rdval.Related_quote__c];
                    }
                    if(relatedquote.Apttus_Proposal__Opportunity__r.Id!=null){
                    latetestOppty = [Select ID,InterfaceChanged__c, Review_Check__c, MACD_Review_Complete__c,IsDocviewer__c, MACD_RDS_Review_Completed_Status__c, MACD_RDS_Review_Complete_LastTimeStamp__c, RDS_Complete__c from Opportunity where Id=:relatedquote.Apttus_Proposal__Opportunity__r.Id Order By CreatedDate Desc Limit 1];
                    }
                } else{
                    latetestOppty = [Select ID,InterfaceChanged__c, Review_Check__c, MACD_Review_Complete__c,IsDocviewer__c, MACD_RDS_Review_Completed_Status__c, MACD_RDS_Review_Complete_LastTimeStamp__c, RDS_Complete__c from Opportunity where RDS_Deal_Hash__c=:billList[0].PremiseDetails__r.DealHash__r.Id Order By CreatedDate Desc Limit 1];
                    }  
              if(latetestOppty!=null){
                  latetestOppty.InterfaceChanged__c= isInterfaceChange;
                  update latetestOppty;
               billingPortHistorylist = [Select Id,Record_Type__c,SP_Product__c,RDSVersion__c, SP_Site_Id__c, Deal_Id__c,RecordType.Name,BEID__c,PBI_Number__c,Determinant_Set_ID__c, Product_Record_Type__c,SP_Product__r.Deal__r.Id,Product_Detail__c, product_name__c from Product_Pricing__c where SP_Site_Id__c IN: clonedPremiseNumberSet and SP_Product__r.Deal__r.Id=:latetestOppty.Id];               
               for(Product_Pricing__c prodPrice: [SELECT Id, list_price__c, Deal_Id__c, SP_Site_Id__c, Record_Type__c, BEID__c From Product_Pricing__c where SP_Site_Id__c=: clonedPremiseNumberSet AND Record_Type__c = 'Access' AND list_price__c !=0.00 AND Deal_Id__c =:latetestOppty.Id]) {
                     siteAmountsMap.put(prodPrice.SP_Site_Id__c, prodPrice.list_price__c);
                     siteBEIDMap.put(prodPrice.SP_Site_Id__c, prodPrice.BEID__c);
               } 
              }
             for(RDS_BillingRelatedElements__c bill : billList){
                    for(RDS_Premise_Details__c pd : clonedPremIdList){
                               if(bill.Billing_Premise_Number__c == pd.Premise_Number__c ){
                                String soql = API_Utils.getCreatableFieldsSOQL('RDS_BillingRelatedElements__c', 'id=\''+bill.Id+'\'');   
                                RDS_BillingRelatedElements__c billD = (RDS_BillingRelatedElements__c)Database.query(soql);
                                RDS_BillingRelatedElements__c newBillD = billD.clone(false,true,true,true);
                                newBillD.PremiseDetails__c = pd.Id;
                                newBillD.MACD_Type__c = MACDConstant.C;
    
                                if(billingPortHistorylist!=null && validationList!=null){
                                for(Product_Pricing__c pp:billingPortHistorylist){
                                 for(RDS_Validation__c rdvali:validationList){
                                  if(rdvali.Premise_Number__c ==pp.SP_Site_Id__c && ( rdvali.MACD_Change_Type__c == SIConstants.UBBAdd ||  rdvali.MACD_Change_Type__c == SIConstants.UBBChange || rdvali.MACD_Change_Type__c == SIConstants.UBBRemove ||  rdvali.MACD_Change_Type__c==SIConstants.PortSpeedChange || rdvali.MACD_Change_Type__c==MACDConstant.PORTACCESS_SPEED_CHANGE) ){
                                     if(pp.BEID__c!= null && newBillD.ChargeType__c==SIConstants.RECORDTYPEPORT && pp.SP_Site_Id__c==bill.Billing_Premise_Number__c && pp.Record_Type__c==SIConstants.RECORDTYPEPORT ){
                                      if (pp.BEID__c != newBillD.Charge_Element_ID__c && (pp.Product_Detail__c == MACDConstant.PORTSPEED_FEE || pp.Product_Detail__c == MACDConstant.TRANSPORTSPEED)){                                      
                                      newBillD.Change_Charge_Element_ID__c =pp.BEID__c;
                                          }
                                      }
                                     else if((rdvali.MACD_Change_Type__c != SIConstants.UBBAdd && rdvali.MACD_Change_Type__c != SIConstants.UBBChange && rdvali.MACD_Change_Type__c != SIConstants.UBBRemove) && rdvali.Class_of_Service__c == SpecialCharacterBuyflowConstant.TRUE_CAMEL_LITERAL && (pp.Record_Type__c == MACDConstant.FEATURE && pp.Product_Detail__c == MACDConstant.PORTCOS) && (newBillD.Product_Detail__c == MACDConstant.COSFEE || newBillD.Product_Detail__c == MACDConstant.PORTCOS) && (newBillD.Product_Detail__c != MACDConstant.VLANS_LOGICAL_CHANNEL && newBillD.Product_Detail__c != MACDConstant.PORTUNILINK && newBillD.Product_Detail__c != MACDConstant.ADDITIONALDNS_FEE) && newBillD.Product_Detail__c != SpecialCharacterBuyflowConstant.CONCAT && newBillD.Product_Detail__c != null && pp.BEID__c != newBillD.Charge_Element_ID__c){                                                                                                                                                             
                                          newBillD.Change_Charge_Element_ID__c =pp.BEID__c;                                                                                                                          
                                      }else if((rdvali.MACD_Change_Type__c != SIConstants.UBBAdd &&  rdvali.MACD_Change_Type__c != SIConstants.UBBChange && rdvali.MACD_Change_Type__c != SIConstants.UBBRemove) && rdvali.Unilink__c == SpecialCharacterBuyflowConstant.TRUE_CAPS_LITERAL && pp.Record_Type__c == MACDConstant.FEATURE && (newBillD.Product_Detail__c == MACDConstant.VLANS_LOGICAL_CHANNEL || newBillD.Product_Detail__c == MACDConstant.PORTUNILINK) && (newBillD.Product_Detail__c != MACDConstant.COSFEE && newBillD.Product_Detail__c != MACDConstant.PORTCOS && newBillD.Product_Detail__c != MACDConstant.ADDITIONALDNS_FEE) && newBillD.Product_Detail__c != SpecialCharacterBuyflowConstant.CONCAT && newBillD.Product_Detail__c != null){
                                            if(pp.BEID__c != newBillD.Charge_Element_ID__c){                                                                                 
                                          newBillD.Change_Charge_Element_ID__c =pp.BEID__c;                                           
                                          }                                                                        
                                      } else if(rdvali.Unilink__c == SpecialCharacterBuyflowConstant.TRUE_CAPS_LITERAL && pp.Record_Type__c == MACDConstant.ACCESS && (newBillD.Product_Detail__c == MACDConstant.ACCESSSPEED_FEE || newBillD.Product_Detail__c == MACDConstant.ACCESSSPEED) && pp.BEID__c != newBillD.Charge_Element_ID__c){                                          
                                          newBillD.Change_Charge_Element_ID__c =pp.BEID__c;                                              
                                        if(newBillD.Change_Charge_Element_ID__c==SpecialCharacterBuyflowConstant.CONCAT|| newBillD.Change_Charge_Element_ID__c==null){
                                          newBillD.Change_Charge_Element_ID__c =pp.BEID__c;  
                                          }                                    
                                        }
                                      }
                                    }
                                  }
                                }
                                if(stat != MACDConstant.COSREMOVE || (stat == MACDConstant.COSREMOVE && newBillD.Product_Detail__c != MACDConstant.COSFEE && newBillD.Product_Detail__c!=MACDConstant.PORTCOS) ){
                                   cloneBillList.add(newBillD);
                               }
                               }
                            }  
                        }
            
            /* Logic to create BRE for newly added CoS */                                                     
            if(stat == MACDConstant.COSADD){
                if(billingPortHistorylist!=null && validationList!=null){
                    for(Product_Pricing__c pp:billingPortHistorylist){
                        if((pp.Product_Detail__c==MACDConstant.COSFEE || pp.Product_Detail__c==MACDConstant.PORTCOS  ) && pp.Record_Type__c == MACDConstant.FEATURE){
                        RDS_BillingRelatedElements__c billD = new RDS_BillingRelatedElements__c();
                        BillD.Charge_Element_ID__c =pp.BEID__c;   
                        BillD.ChargeType__c=pp.RecordType.Name;
                        BillD.Product_Detail__c=pp.Product_Detail__c;
                        BillD.Currency_Code__c=MACDConstant.USD;
                        BillD.PremiseDetails__c = clonedPremIdList[0].Id;
                        cloneBillList.add(BillD);
                        }
                    }
                }
            }
            /* End Logic to create BRE for newly added CoS */
               
        if(cloneBillList.size()>0){ 
            try{
            insert cloneBillList;
            }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
          }
       
  //Added The logic for Deletion of the One Time Fee Record for the MACD Billing-Related Elements. Defect Id-82690      
          if(cloneBillList.size()>0 && cloneBillList != null){
          
           for(RDS_BillingRelatedElements__c rdsbilling : cloneBillList){
           
             if(rdsbilling.Product_Detail__c == MACDConstant.ONETIME_FEE){
               accBillListtodelete.add(rdsbilling);
             }           
           }
           if(accBillListtodelete.size()>0 && accBillListtodelete != null){
             try{
             delete accBillListtodelete;
             }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }            
           }
          }
        }
        
     /***********************************************************************************************************************************************************/   
        
     /****************************RDS Contact Block**************************************************************************************************************/
     
      List<RDS_Contact__c> conList = [Select Id, RDS_Premise_Details_Number__c,RDS_Premise_Details_Number__r.ID, RDS_Premise_Details_Number__r.Premise_Number__c from RDS_Contact__c Where RDS_Premise_Details_Number__r.ID IN: OldpremiseSetID];
       
        if(conList.size()>0 && clonedPremIdList.size()>0){
            for(RDS_Contact__c rdCon : conList){
                    for(RDS_Premise_Details__c pd : clonedPremIdList){
                        if(rdCon.RDS_Premise_Details_Number__r.Premise_Number__c == pd.Premise_Number__c){
                            String soql = API_Utils.getCreatableFieldsSOQL('RDS_Contact__c', 'id=\''+rdCon.Id+'\'');   
                            RDS_Contact__c rdsCon = (RDS_Contact__c)Database.query(soql);
                            RDS_Contact__c newRDSCon = rdsCon.clone(false,true,true,true);
                            newRDSCon.RDS_Premise_Details_Number__c = pd.Id;
                            newRDSCon.MACD_Type__c = MACDConstant.C;
                            cloneConList.add(newRDSCon);
                        }
                    }
            }  
     
        if(cloneConList.size()>0){ 
            try{
            insert cloneConList;
             }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
        }
       }
     
     /**********************************************************************************************************************************************/
     
     /***********************************************RDS Competitive Discount***********************************************************************/
     
     
     List<RDS_Competitive_Discount__c> compList = [Select Id, PremiseDetails__c,PremiseDetails__r.ID, PremiseDetails__r.Premise_Number__c from RDS_Competitive_Discount__c Where PremiseDetails__r.ID IN: OldpremiseSetID];
       
        if(compList.size()>0 && clonedPremIdList.size()>0){
            for(RDS_Competitive_Discount__c rdCom : compList){
                    for(RDS_Premise_Details__c pdt : clonedPremIdList){
                        if(rdCom.PremiseDetails__r.Premise_Number__c == pdt.Premise_Number__c){
                            String soql = API_Utils.getCreatableFieldsSOQL('RDS_Competitive_Discount__c', 'id=\''+rdCom.Id+'\'');   
                            RDS_Competitive_Discount__c rdsComp = (RDS_Competitive_Discount__c)Database.query(soql);
                            RDS_Competitive_Discount__c newRDSComp = rdsComp.clone(false,true,true,true);
                            newRDSComp.PremiseDetails__c = pdt.Id;
                            newRDSComp.MACD_Type__c = MACDConstant.C;
                            cloneCompDiscList.add(newRDSComp);
                        }
                    }
            }  
                 
      if(cloneCompDiscList.size()>0){ 
            try{
            insert cloneCompDiscList;
            }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
        }       
     }
  
     /**********************************************************************************/
     
      
     if(valIds.size()>0){
         for(RDS_Validation_Configuration__c rCon : [Select Id, RDS_Validation__c, MACD_Change_Feature__c, Validation_Premise_Number__c, VLANID__c, Ingress_Profile_ID__c, Egress_Profile_ID__c,V6_Routing_Protocol__c,V6_Routing_ASN__c,V6_Send_Default_Indicator__c,V6_ASN_Override_Indicator__c,V6_Encrypted_Password__c,V4_Encrypted_Password__c,V4_Routing_Protocol__c,V4_Routing_ASN__c,V4_Send_Default_Indicator__c,V4_ASN_Override_Indicator__c, VLAN_Speed__c from RDS_Validation_Configuration__c where RDS_Validation__c IN: valIds ]){
             validConMap.put(rCon.VLANID__c,rCon);
         } 
    } 
    
    for(Circuit_and_VLAN_Details__c cv: [Select Id, CVLAN_Premise_Number__c from Circuit_and_VLAN_Details__c where Id =: macdCVLANIdSet]){
        macdCVLANMap.put(cv.CVLAN_Premise_Number__c,cv);        // map of CVLAN records that were created because of MACD Change
    }
     
    if(masterCVLANIdSet.size()>0){
         accCktIdList = [Select Id,LAI__c,MLPPP_Link_Number__c, RDS_Premise_Number__c,GroupPortID__c, Circuit_and_VLAN_Details__c, circuitStatus__c, Access_Circuit_ID__c from RDS_Access_Circuit_ID__c where circuitStatus__c != 'Deleted' AND Circuit_and_VLAN_Details__c =: masterCVLANIdSet];
         albIdList = [Select Id, ALB_Premise_Number__c, Circuit_and_VLAN_Details__c  from RDS_ALB_Access_Circuits__c where Circuit_and_VLAN_Details__c =: masterCVLANIdSet];
         rdsSWIPCon = [Select Id, RDS_SWIP_Contact_Premise_Number__c, Circuit_and_VLAN_Details__c  from RDS_SWIP_Contacts__c where Circuit_and_VLAN_Details__c =: masterCVLANIdSet];
         vlanList = [Select Id, Circuit_and_VLAN_Details__c,VLAN_Speed__c, VLANID__c,VLAN_Premise_Number__c, INSTAR_Order_Number__c, External_ID__c, VLAN_Status__c,USO_Number__c from VLAN_Information__c where VLAN_Status__c != 'Deleted' AND Circuit_and_VLAN_Details__c =: masterCVLANIdSet];
         vpnList = [Select Id, VPN_Premise_Number__c, Circuit_and_VLAN_Details__c  from RDS_VPN_Data__c where Circuit_and_VLAN_Details__c =: masterCVLANIdSet];
         histList = [Select Id, History_Premise_Number__c, RDSCircuitVLANDetails__c from RDS_History_Tracking__c where RDSCircuitVLANDetails__c =: masterCVLANIdSet];
         v4FamShortList = [Select Id, V4_Family_Premise_Number__c, RDS_Circuit_and_VLAN_Details_V4__c, Routing_Protocol__c, Routing_ASN__c, Send_Default_Indicator__c, ASN_Override_Indicator__c, Encrypted_Password__c, Unencrypted_Password__c from RDS_V4_Family_Data__c where RDS_Circuit_and_VLAN_Details_V4__c =: masterCVLANIdSet Order By Id asc];
         v6FamShortList = [Select Id, V6_Family_Premise_Number__c, RDS_Circuit_and_VLAN_Details_V6__c, Routing_Protocol__c, Routing_ASN__c, Send_Default_Indicator__c, AS_Override_Indicator__c, Encrypted_Password__c, Unencrypted_Password__c from V6_Family_Data__c where RDS_Circuit_and_VLAN_Details_V6__c =: masterCVLANIdSet Order By Id asc];       
    }
     
     if(accCktIdList.size()>0){
        for(RDS_Access_Circuit_ID__c a : accCktIdList){
            if(premCktMap.containsKey(a.RDS_Premise_Number__c)){
                List<RDS_Access_Circuit_ID__c> accList = premCktMap.get(a.RDS_Premise_Number__c);
                accList.add(a);
                premCktMap.put(a.RDS_Premise_Number__c,accList);
            } else {
                premCktMap.put(a.RDS_Premise_Number__c,new List<RDS_Access_Circuit_ID__c> { a });
            }
         }    
     Integer j = 1;
     Integer i = 1;
     accBillList = [Select Id, RDS_Access_Circuit_ID__c from RDS_Access_Billing_Element_Details__c where RDS_Access_Circuit_ID__c =: accCktIdList];
         if(upgrade == 0 && stat == MACDConstant.PORTACCESSSPEEDCHANGE && !isEthernetAccessChange){
             for(String clan :macdCVLANMap.keyset()){
                 for(RDS_Access_Circuit_ID__c ackt :accCktIdList){
                     if(ackt.RDS_Premise_Number__c == clan){
                                 String soqlCKT = API_Utils.getCreatableFieldsSOQL('RDS_Access_Circuit_ID__c', 'id=\''+ackt.Id+'\'');    
                                 RDS_Access_Circuit_ID__c ckt = (RDS_Access_Circuit_ID__c )Database.query(soqlCKT);
                                 RDS_Access_Circuit_ID__c newCKT = ckt.clone(false,true,true,true);
                                 newCKT.Circuit_and_VLAN_Details__c = macdCVLANMap.get(ackt.RDS_Premise_Number__c).Id;
                                 newCKT.MACD_Type__c = MACDConstant.C;
                                 newCKT.Master_of_Clone__c = ackt.Id;
                                 newCKT.Change_Cloned__c = True;
                                 newCKT.MLPPP_Link_Number__c = String.valueOf(j);
                                 if(j <= cktCount){
                                     newCKT.circuitStatus__c = SpecialCharacterBuyflowConstant.CONCAT;
                                     if(cktCount == 1){
                                         String acId = ackt.Access_Circuit_ID__c;
                                         String subAcId = acId.left(12);
                                         newCKT.Access_Circuit_ID__c = subAcId+ MACDConstant.SIVARConst_ATI;
                                         newCKT.USO_Number__c = SpecialCharacterBuyflowConstant.CONCAT;     
                                         newCKT.MLPPP_Link_Number__c = SpecialCharacterBuyflowConstant.CONCAT;
                                         newCKT.circuitStatus__c = MACDConstant.PENDINGCHANGE;
                                     }
                                 } else {
                                     newCKT.circuitStatus__c = MACDConstant.PENDINGDELETE;
                                     newCKT.USO_Number__c = SpecialCharacterBuyflowConstant.CONCAT;
                                 }
                                 accCKTToClone.add(newCkT);
                                 j = j +1;
                     }
                 }
             }
         } else if(upgrade == 1 && stat == MACDConstant.PORTACCESSSPEEDCHANGE && !isEthernetAccessChange){
                 for(String clan :macdCVLANMap.keyset()){
                     for(RDS_Access_Circuit_ID__c ackt :accCktIdList){
                         if(ackt.RDS_Premise_Number__c == clan){
                                 List<RDS_Access_Circuit_ID__c> aList = premCktMap.get(ackt.RDS_Premise_Number__c);
                                 existingCktCount = aList.size();
                                     String soqlCKT = API_Utils.getCreatableFieldsSOQL('RDS_Access_Circuit_ID__c', 'id=\''+ackt.Id+'\'');    
                                     RDS_Access_Circuit_ID__c ckt = (RDS_Access_Circuit_ID__c )Database.query(soqlCKT);
                                     RDS_Access_Circuit_ID__c newCKT = ckt.clone(false,true,true,true);
                                     newCKT.Circuit_and_VLAN_Details__c = macdCVLANMap.get(ackt.RDS_Premise_Number__c).Id;
                                     newCKT.MACD_Type__c = MACDConstant.C;
                                     newCKT.Master_of_Clone__c = ackt.Id;
                                     newCKT.USO_Number__c = SpecialCharacterBuyflowConstant.CONCAT;
                                     newCKT.MLPPP_Link_Number__c = String.valueOf(i);
                                     if(i <= existingCktCount){
                                         newCKT.circuitStatus__c = MACDConstant.PENDINGCHANGE;
                                         newCKT.Change_Cloned__c = True;                                         
                                     }
                                     String acId = ackt.Access_Circuit_ID__c;
                                     String subAcId = acId.left(12);
                                     newCKT.Access_Circuit_ID__c = subAcId+'/80'+i+'/ATI';
                                     accCKTToClone.add(newCkT);
                                     i = i + 1;
                                     acktRefId = ackt.Id;
                                     acktRefPremiseNum = ackt.RDS_Premise_Number__c;
                                     acktIdString = ackt.Access_Circuit_ID__c;
                                     mastergroupid = ackt.GroupPortID__c; 
                                     masterLAInumber = ackt.LAI__c;
                         }
                     }
                  }
                  Integer k = i;
                  if(i<=cktCount){
                    for(i = k; i <= cktCount; i++){
                        String soqlCKT = API_Utils.getCreatableFieldsSOQL('RDS_Access_Circuit_ID__c', 'id=\''+acktRefId+'\'');    
                                     RDS_Access_Circuit_ID__c ckt = (RDS_Access_Circuit_ID__c )Database.query(soqlCKT);
                                     RDS_Access_Circuit_ID__c newCKT = ckt.clone(false,true,true,true);
                                     newCKT.Circuit_and_VLAN_Details__c = macdCVLANMap.get(acktRefPremiseNum).Id;
                                     newCKT.MACD_Type__c = MACDConstant.C;
                                     newCKT.Master_of_Clone__c = acktRefId;
                                     newCKT.USO_Number__c = SpecialCharacterBuyflowConstant.CONCAT;
                                     newCKT.MLPPP_Link_Number__c = String.valueOf(i);
                                     newCKT.circuitStatus__c = MACDConstant.PENDINGADD;
                                     newCKT.Change_Cloned__c = True;
                                     String acId = acktIdString;
                                     String subAcId = acId.left(12);
                                     newCKT.Access_Circuit_ID__c = subAcId+MACDConstant.SIVARConst_801+i+MACDConstant.ATI;
                                     newCKT.GroupPortID__c = mastergroupid;
                                     newCKT.LAI__c = masterLAInumber;
                                     accCKTToClone.add(newCkT);
                    }
                  }
         } else{
             for(String clan :macdCVLANMap.keyset()){
                 for(RDS_Access_Circuit_ID__c ackt :accCktIdList){
                     if(ackt.RDS_Premise_Number__c == clan){
                         String soqlCKT = API_Utils.getCreatableFieldsSOQL('RDS_Access_Circuit_ID__c', 'id=\''+ackt.Id+'\'');    
                         RDS_Access_Circuit_ID__c ckt = (RDS_Access_Circuit_ID__c )Database.query(soqlCKT);
                         RDS_Access_Circuit_ID__c newCKT = ckt.clone(false,true,true,true);
                         newCKT.Circuit_and_VLAN_Details__c = macdCVLANMap.get(ackt.RDS_Premise_Number__c).Id;
                         newCKT.MACD_Type__c = MACDConstant.C;
                         newCKT.Master_of_Clone__c = ackt.Id;
                         newCKT.Change_Cloned__c = True;
                         if(stat==MACDConstant.PORTACCESSSPEEDCHANGE && isEthernetAccessChange && !isInterfaceChange){
                             newCKT.circuitStatus__c = MACDConstant.PENDINGCHANGE;
                             newCKT.USO_Number__c = SpecialCharacterBuyflowConstant.CONCAT;                             
                         }
                         accCKTToClone.add(newCkT);
                     }
                 }
             }
         }
     }
     
     if(accCKTToClone.size()>0){
         try{
            insert accCKTToClone;
         }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
     }
     
     List<RDS_Access_Circuit_ID__c> clonedACKT = [Select Id, Master_of_Clone__c, RDS_Premise_Number__c, Premise_Service_Type__c, RDS_PremiseDetailID__c, circuitStatus__c from RDS_Access_Circuit_ID__c where Id =: accCKTToClone AND circuitStatus__c != 'Pending_Delete'];
     
     if(clonedPremIdList.size()>0){
         for(RDS_Premise_Details__c p : clonedPremIdList){
             String premId = p.Id;
             String subPremId = premId.substring(0,15);
             premiseMap.put(subPremId, p);
             premiseNumberSet.add(p.Premise_Number__c);
         }
     }
     
     if(clonedACKT.size()>0){
         for(RDS_Access_Circuit_ID__c a : clonedACKT){
             accessCktMap.put(a.Id, a);
         }
     }
     
     if(stat==MACDConstant.PORTACCESSSPEEDCHANGE){
        if(premiseMap.size()>0 && accessCktMap.size()>0){
           for(RDS_Premise_Details__c rdsP: premiseMap.values()){
               circuitCount =1;   
                  if (newPortSpeedNum > 1){
                        circuitCount = cktCount;
                  }
                        if(siteAmountsMap.size()>0){
                            accessAmount = siteAmountsMap.get(rdsP.Premise_Number__c); 
                        } 
                        Decimal accessOverrideRateAmount = accessAmount/circuitCount;            
                           for(RDS_Access_Circuit_ID__c accessCkt : accessCktMap.values()){
                                if(accessCkt.RDS_PremiseDetailID__c == rdsP.Id){
                                    RDS_Access_Billing_Element_Details__c accessBillingrecord = new RDS_Access_Billing_Element_Details__c();
                                    if(accessCkt.Premise_Service_Type__c == MACDConstant.AVPN || accessCkt.Premise_Service_Type__c== MACDConstant.MIS){
                                        accessBillingrecord.Access_Override_Rate_Amount__c = String.valueof(accessOverrideRateAmount);
                                    }                          
                                        accessBillingrecord.RDS_Access_Circuit_ID__c = accessCkt.Id;
                                        if(siteBEIDMap.size()>0){
                                            accessBillingrecord.Access_Charge_Element_ID__c = siteBEIDMap.get(accessCkt.RDS_Premise_Number__c);
                                        }
                                        accBillToCloneList.add(accessBillingrecord);
                                    }
                            }
            }
        }     
     } else{
         if(accCktIdList.size()>0){
             if(accBillList.size()>0){
                 if(clonedACKT.size()>0){
                    for(RDS_Access_Circuit_ID__c rack : accCktIdList){
                        for(RDS_Access_Circuit_ID__c Cack : clonedACKT){
                             for(RDS_Access_Billing_Element_Details__c acb :accBillList){
                                 if(acb.RDS_Access_Circuit_ID__c == rack.Id && Cack.RDS_Premise_Number__c == rack.RDS_Premise_Number__c && Cack.Master_of_Clone__c == rack.Id){
                                     String soqlACB = API_Utils.getCreatableFieldsSOQL('RDS_Access_Billing_Element_Details__c', 'id=\''+acb.Id+'\'');    
                                     RDS_Access_Billing_Element_Details__c billA = (RDS_Access_Billing_Element_Details__c )Database.query(soqlACB);
                                     RDS_Access_Billing_Element_Details__c newbillA = billA.clone(false,true,true,true);
                                     newbillA.RDS_Access_Circuit_ID__c = Cack.Id;
                                     newbillA.MACD_Type__c = MACDConstant.C;
                                     accBillToCloneList.add(newbillA);
                                 }
                             }
                        }
                    }
                 }
             }
        }
    }
    
     if(accBillToCloneList.size()>0){
         try{
            insert accBillToCloneList;
         }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
     } 
     
     if(albIdList.size()>0){
         for(String clan :macdCVLANMap.keyset()){
             for(RDS_ALB_Access_Circuits__c alb :albIdList){
                 if(alb.ALB_Premise_Number__c == clan){
                     String soqlALB = API_Utils.getCreatableFieldsSOQL('RDS_ALB_Access_Circuits__c', 'id=\''+alb.Id+'\'');    
                     RDS_ALB_Access_Circuits__c albRec = (RDS_ALB_Access_Circuits__c)Database.query(soqlALB);
                     RDS_ALB_Access_Circuits__c newALB = albRec.clone(false,true,true,true);
                     newALB.Circuit_and_VLAN_Details__c = macdCVLANMap.get(alb.ALB_Premise_Number__c).Id;
                     newALB.MACD_Type__c = MACDConstant.C;
                     albToClone.add(newALB);
                 }
             }
         }
     }
     
     if(albToClone.size()>0){
         try{
            insert albToClone;
          }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
     }
     for (COS_Value__c CoS : [SELECT COS_1__c, COS_2__c, COS_3__c, COS_4__c, COS_5__c, COS_6__c, Egress_COS_Profile_ID__c, Egress_PPCOS__c, Ingress_COS_Profile_ID__c, Ingress_PPCOS__c, Package_AVPN__c, Prof_E_Value__c, Product__c FROM COS_Value__c]) {
        cosmaps.put(CoS.Ingress_COS_Profile_ID__c,CoS);
     }
     
     if(validSetId != null){
         validationlists = [select id,Port_Speed__c,Current_Port_Speed__c,COS_Profile_ID__c,Ingress_COS_Profile_ID__c,Egress_COS_Profile_ID__c,Premise_Number__c,MACD_Change_Type__c,Related_quote__c,Unilink__c from RDS_Validation__c where id IN : validSetId];
             for(RDS_Validation__c v : validationlists){                
                 validationMap.put(v.Premise_Number__c, v);             
             }
     }
         
     if(vlanList.size()>0){
         v4FamLongList = [Select Id, V4_Family_Premise_Number__c, RDS_VLAN_Information_V4__c, Routing_Protocol__c, Routing_ASN__c, Send_Default_Indicator__c, ASN_Override_Indicator__c, Encrypted_Password__c, Unencrypted_Password__c from RDS_V4_Family_Data__c where RDS_VLAN_Information_V4__c =: vlanList Order By Id asc];
         v6FamLongList = [Select Id, V6_Family_Premise_Number__c, RDS_VLAN_Information__c, Routing_Protocol__c, Routing_ASN__c, Send_Default_Indicator__c, AS_Override_Indicator__c, Encrypted_Password__c, Unencrypted_Password__c from V6_Family_Data__c where RDS_VLAN_Information__c =: vlanList Order By Id asc];    
         
                 for(VLAN_Information__c vl :vlanList){
                     for(Circuit_and_VLAN_Details__c cvlans :macdCVLANMap.values()){
                      String clan = cvlans.CVLAN_Premise_Number__c;
                        if(vl.VLAN_Premise_Number__c == clan){
                             String soqlvl = API_Utils.getCreatableFieldsSOQL('VLAN_Information__c', 'id=\''+vl.Id+'\'');    
                             VLAN_Information__c vlRec = (VLAN_Information__c)Database.query(soqlvl);
                             VLAN_Information__c newvl = vlRec.clone(false,true,true,true);
                             newvl.Circuit_and_VLAN_Details__c = macdCVLANMap.get(vl.VLAN_Premise_Number__c).Id;
                             if(validConMap.containsKey(newvl.VLANID__c) && validConMap.get(vl.VLANID__c).MACD_Change_Feature__c==MACDConstant.VLANDISCONNECTED){
                                newvl.VLAN_Status__c = MACDConstant.PENDINGDISCONNECT;
                                newvl.Disconnected__c = true;
                                newvl.USO_Number__c = SpecialCharacterBuyflowConstant.CONCAT;
                             } else if(validConMap.containsKey(newvl.VLANID__c) && (validConMap.get(vl.VLANID__c).MACD_Change_Feature__c==MACDConstant.COSCHANGE || validConMap.get(vl.VLANID__c).MACD_Change_Feature__c==MACDConstant.ADDCOS) && validationMap.get(clan).Unilink__c == SpecialCharacterBuyflowConstant.TRUE_LITERAL) {
                               newvl.Ingress_COS_Profile_ID__c = validConMap.get(newvl.VLANID__c).Ingress_Profile_ID__c;
                               newvl.Egress_COS_Profile_ID__c =  validConMap.get(newvl.VLANID__c).Egress_Profile_ID__c;
                               
                             } else if(validationMap.containsKey(clan) && (validationMap.get(clan).MACD_Change_Type__c==MACDConstant.COSCHANGE) && (validationMap.get(clan).Unilink__c == SpecialCharacterBuyflowConstant.FALSE_LITERAL || validationMap.get(clan).Unilink__c == SpecialCharacterBuyflowConstant.CONCAT || validationMap.get(clan).Unilink__c == null)) {
                               newvl.Ingress_COS_Profile_ID__c = validationMap.get(clan).Ingress_COS_Profile_ID__c;
                               newvl.Egress_COS_Profile_ID__c =  validationMap.get(clan).Egress_COS_Profile_ID__c; 
                             } else if(validConMap.containsKey(newvl.VLANID__c) && validConMap.get(vl.VLANID__c).MACD_Change_Feature__c==MACDConstant.REMOVECOS) {
                                newvl.Ingress_COS_Profile_ID__c = MACDConstant.SIVARConst_125;
                                newvl.Egress_COS_Profile_ID__c =  MACDConstant.SIVARConst_125;
                             } else if(validConMap.containsKey(newvl.VLANID__c) && validConMap.get(vl.VLANID__c).MACD_Change_Feature__c==MACDConstant.VLANSPEED_CHANGE) {
                               newvl.VLAN_Speed__c = validConMap.get(newvl.VLANID__c).VLAN_Speed__c;
                               if(validConMap.get(newvl.VLANID__c).VLAN_Speed__c!= vlRec.VLAN_Speed__c){
                                   newvl.VLAN_Status__c=MACDConstant.PENDINGCHANGE;
                                   newvl.USO_Number__c = SpecialCharacterBuyflowConstant.CONCAT;
                               }
                             }
                             if(stat == MACDConstant.PORTSPEEDCHANGE){
                               
                               if(validationMap.get(clan).Unilink__c == SpecialCharacterBuyflowConstant.FALSE_LITERAL && validationMap.get(clan).Unilink__c == SpecialCharacterBuyflowConstant.FALSE_CAMEL_LITERAL){
                                   newvl.VLAN_Speed__c = validationMap.get(clan).Current_Port_Speed__c;
                                } 
                             }
                             if(stat == MACDConstant.PORTACCESSSPEEDCHANGE){
                               
                               if(validationMap.get(clan).Unilink__c == SpecialCharacterBuyflowConstant.FALSE_LITERAL && isEthernetAccessChange){                                                                    
                                       newvl.VLAN_Status__c=MACDConstant.PENDINGCHANGE;
                                       newvl.VLAN_Speed__c = String.valueOf(newPortSpeedNum);
                                   if(!isInterfaceChange ){
                                       newvl.USO_Number__c = SpecialCharacterBuyflowConstant.CONCAT;
                                   }
                               }else if(validationMap.get(clan).Unilink__c == SpecialCharacterBuyflowConstant.TRUE_LITERAL){
                                 newvl.VLAN_Speed__c = vl.VLAN_Speed__c;
                                 newvl.USO_Number__c = vl.USO_Number__c;
                                 
                               }
                             }

                             newvl.MACD_Type__c = MACDConstant.C;
                             newvl.Validation_Record_Id__c = SpecialCharacterBuyflowConstant.CONCAT;
                             newvl.Add_VLAN__c = false;
                             if((validationMap.get(clan).MACD_Change_Type__c == MACDConstant.COSCHANGE || validationMap.get(clan).MACD_Change_Type__c == MACDConstant.ADDCOS) && (validationMap.get(clan).Unilink__c == SpecialCharacterBuyflowConstant.FALSE_LITERAL || validationMap.get(clan).Unilink__c == SpecialCharacterBuyflowConstant.CONCAT)){
                                 newvl.Ingress_COS_Profile_ID__c = validationMap.get(clan).COS_Profile_ID__c;
                                 newvl.Egress_COS_Profile_ID__c = validationMap.get(clan).Egress_COS_Profile_ID__c;
                             }
                             if(macdCVLANMap.size()>0 && macdCVLANMap != null && ( validationMap.get(clan).Unilink__c == SpecialCharacterBuyflowConstant.FALSE_LITERAL || validationMap.get(clan).Unilink__c == SpecialCharacterBuyflowConstant.CONCAT || validationMap.get(clan).Unilink__c == null ) && validationMap.get(clan).MACD_Change_Type__c != MACDConstant.REMOVECOS){
                                 if(cosmaps.get(newvl.Ingress_COS_Profile_ID__c).Package_AVPN__c !=null){
                                     CVLANmappackage.put(cvlans.id,cvlans);                               
                                 }
                             }
                             vlanToClone.add(newvl);
                      }
                  } 
               } 
     }
     
     if(CVLANmappackage.size()>0){
      update CVLANmappackage.values();
     }
     if(vlanToClone.size()>0){
         try{
            insert vlanToClone;
         }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
     }
     List<VLAN_Information__c> clonedVLAN = [Select Id, VLAN_Premise_Number__c, VLANID__c from VLAN_Information__c where Id =: vlanToClone];
     
     if(vlanList.size()>0){
         if(v4FamLongList.size()>0){
             if(clonedVLAN.size()>0){
                for(VLAN_Information__c rvl : vlanList){
                    for(VLAN_Information__c Cvl : clonedVLAN){
                         for(RDS_V4_Family_Data__c vl :v4FamLongList){
                             if(vl.RDS_VLAN_Information_V4__c == rvl.Id && Cvl.VLAN_Premise_Number__c == rvl.VLAN_Premise_Number__c && Cvl.VLANID__c == rvl.VLANID__c){
                                 String soqlvl = API_Utils.getCreatableFieldsSOQL('RDS_V4_Family_Data__c', 'id=\''+vl.Id+'\'');    
                                 RDS_V4_Family_Data__c vln = (RDS_V4_Family_Data__c)Database.query(soqlvl);
                                 RDS_V4_Family_Data__c newVLN = vln.clone(false,true,true,true);
                                 newVLN.RDS_VLAN_Information_V4__c = Cvl.Id;
                                 newVLN.MACD_Type__c = MACDConstant.C;
                                 newVLN.Cloned_From__c = vl.Id;
                                 //Added for VLAN Add
                             /*/    if (stat == MACDConstant.ADD){
                                     if(!validConMap.isEmpty() && validConMap.get(Cvl.VLANID__c)!=null){
                                         if(validConMap.get(Cvl.VLANID__c).V4_Encrypted_Password__c!=null) {
                                            newVLN.Encrypted_Password__c=validConMap.get(Cvl.VLANID__c).V4_Encrypted_Password__c;
                                         }
                                            newVLN.Routing_Protocol__c=validConMap.get(Cvl.VLANID__c).V4_Routing_Protocol__c;
                                            newVLN.Routing_ASN__c=validConMap.get(Cvl.VLANID__c).V4_Routing_ASN__c;
                                            newVLN.Send_Default_Indicator__c=validConMap.get(Cvl.VLANID__c).V4_Send_Default_Indicator__c;
                                            newVLN.ASN_Override_Indicator__c=validConMap.get(Cvl.VLANID__c).V4_ASN_Override_Indicator__c;
                                     }
                                 }/*/
                                 v4FamLongListToClone.add(newVLN);
                             }
                         }
                    }
                }
             }
         }
    }
     
     if(v4FamLongListToClone.size()>0){
         try{
            insert v4FamLongListToClone;
         }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
     } 
     
     if(vlanList.size()>0){
         if(v6FamLongList.size()>0){
             if(clonedVLAN.size()>0){
                for(VLAN_Information__c rvl6 : vlanList){
                    for(VLAN_Information__c Cvl6 : clonedVLAN){
                         for(V6_Family_Data__c vl6 :v6FamLongList){
                             if(vl6.RDS_VLAN_Information__c == rvl6.Id && Cvl6.VLAN_Premise_Number__c == rvl6.VLAN_Premise_Number__c && Cvl6.VLANID__c == rvl6.VLANID__c){
                                 String soqlvl6 = API_Utils.getCreatableFieldsSOQL('V6_Family_Data__c', 'id=\''+vl6.Id+'\'');    
                                 V6_Family_Data__c vln6 = (V6_Family_Data__c)Database.query(soqlvl6);
                                 V6_Family_Data__c newVLN6 = vln6.clone(false,true,true,true);
                                 newVLN6.RDS_VLAN_Information__c = Cvl6.Id;
                                 newVLN6.MACD_Type__c = MACDConstant.C;
                                 newVLN6.Cloned_From__c = vl6.Id;
                                 //Added for VLAN Add
                               /*/  if(stat == MACDConstant.ADD){
                                     if(!validConMap.isEmpty() && validConMap.get(Cvl6.VLANID__c)!=null){
                                         newVLN6.Routing_Protocol__c=validConMap.get(Cvl6.VLANID__c).V6_Routing_Protocol__c;
                                         newVLN6.Routing_ASN__c=validConMap.get(Cvl6.VLANID__c).V6_Routing_ASN__c;
                                         newVLN6.Send_Default_Indicator__c=validConMap.get(Cvl6.VLANID__c).V6_Send_Default_Indicator__c;
                                         newVLN6.AS_Override_Indicator__c=validConMap.get(Cvl6.VLANID__c).V6_ASN_Override_Indicator__c;
                                        if(validConMap.get(Cvl6.VLANID__c).V6_Encrypted_Password__c!=null){
                                         newVLN6.Encrypted_Password__c=validConMap.get(Cvl6.VLANID__c).V6_Encrypted_Password__c;
                                        }
                                     }
                                 }/*/
                                //End
                                 v6FamLongListToClone.add(newVLN6);
                             }
                         }
                    }
                }
             }
         }
    }
     
     if(v6FamLongListToClone.size()>0){
         try{
            insert v6FamLongListToClone;
         }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
     }
     
     if(vpnList.size()>0){
     v4List = [Select Id, RDS_VPN_Data_V4__c from RDS_Mutlicast_V4__c where RDS_VPN_Data_V4__c =: vpnList];
     v6List = [Select Id, RDS_VPN_Data_V6__c from RDS_Mutlicast_V6__c where RDS_VPN_Data_V6__c =: vpnList];
         for(String clan :macdCVLANMap.keyset()){
             for(RDS_VPN_Data__c vp :vpnList){
                 if(vp.VPN_Premise_Number__c == clan){
                     String soqlvp = API_Utils.getCreatableFieldsSOQL('RDS_VPN_Data__c', 'id=\''+vp.Id+'\'');    
                     RDS_VPN_Data__c vpRec = (RDS_VPN_Data__c)Database.query(soqlvp);
                     RDS_VPN_Data__c newvp = vpRec.clone(false,true,true,true);
                     newvp.Circuit_and_VLAN_Details__c = macdCVLANMap.get(vp.VPN_Premise_Number__c).Id;
                     newvp.MACD_Type__c = MACDConstant.C;
                     vpnToClone.add(newvp);
                 }
             }
         }
     }
     
     if(vpnToClone.size()>0){
         try{
            insert vpnToClone;
         } catch(DMLException e){
         }
     }
     
     List<RDS_VPN_Data__c> clonedVPN = [Select Id, VPN_Premise_Number__c from RDS_VPN_Data__c where Id =: vpnToClone];
     
     if(vpnList.size()>0){
         if(v4List.size()>0){
             if(clonedVPN.size()>0){
                for(RDS_VPN_Data__c vOld : vpnList){
                    for(RDS_VPN_Data__c Cv : clonedVPN){
                         for(RDS_Mutlicast_V4__c vpn4 :v4List){
                             if(vpn4.RDS_VPN_Data_V4__c == vOld.Id && Cv.VPN_Premise_Number__c == vOld.VPN_Premise_Number__c){
                                 String soqlv4 = API_Utils.getCreatableFieldsSOQL('RDS_Mutlicast_V4__c', 'id=\''+vpn4.Id+'\'');    
                                 RDS_Mutlicast_V4__c vp4 = (RDS_Mutlicast_V4__c )Database.query(soqlv4);
                                 RDS_Mutlicast_V4__c newvp4 = vp4.clone(false,true,true,true);
                                 newvp4.RDS_VPN_Data_V4__c = Cv.Id;
                                 newvp4.MACD_Type__c = MACDConstant.C;
                                 v4ToClone.add(newvp4);
                             }
                         }
                    }
                }
             }
         }
    }
     
     if(v4ToClone.size()>0){
         try{
            insert v4ToClone;
         }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
     } 
     
     if(vpnList.size()>0){
         if(v6List.size()>0){
             if(clonedVPN.size()>0){
                for(RDS_VPN_Data__c v6Old : vpnList){
                    for(RDS_VPN_Data__c Cv6 : clonedVPN){
                         for(RDS_Mutlicast_V6__c vpn6 :v6List){
                             if(vpn6.RDS_VPN_Data_V6__c == v6Old.Id && Cv6.VPN_Premise_Number__c == v6Old.VPN_Premise_Number__c){
                                 String soqlv6 = API_Utils.getCreatableFieldsSOQL('RDS_Mutlicast_V6__c', 'id=\''+vpn6.Id+'\'');    
                                 RDS_Mutlicast_V6__c vp6 = (RDS_Mutlicast_V6__c )Database.query(soqlv6);
                                 RDS_Mutlicast_V6__c newvp6 = vp6.clone(false,true,true,true);
                                 newvp6.RDS_VPN_Data_V6__c = Cv6.Id;
                                 newvp6.MACD_Type__c = MACDConstant.C;
                                 v6ToClone.add(newvp6);
                             }
                         }
                    }
                }
             }
         }
    }
     
     if(v6ToClone.size()>0){
         try{
            insert v6ToClone;
        }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
     } 
     
     if(rdsSWIPCon.size()>0){
         for(String clan :macdCVLANMap.keyset()){
             for(RDS_SWIP_Contacts__c rCon : rdsSWIPCon){
                 if(rCon.RDS_SWIP_Contact_Premise_Number__c == clan){
                     String soqlRCon = API_Utils.getCreatableFieldsSOQL('RDS_SWIP_Contacts__c', 'id=\''+rCon.Id+'\'');    
                     RDS_SWIP_Contacts__c rConRec = (RDS_SWIP_Contacts__c)Database.query(soqlRCon);
                     RDS_SWIP_Contacts__c newRCon = rConRec.clone(false,true,true,true);
                     newRCon.Circuit_and_VLAN_Details__c = macdCVLANMap.get(rCon.RDS_SWIP_Contact_Premise_Number__c).Id;
                     newRCon.MACD_Type__c = MACDConstant.C;
                     rdsSWIPConToClone.add(newRCon);
                 }
             }
         }
     }
     
     if(rdsSWIPConToClone.size()>0){
         try{
            insert rdsSWIPConToClone;
         }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
     }
     
     if(histList.size()>0){
         for(String clan :macdCVLANMap.keyset()){
             for(RDS_History_Tracking__c htr : histList){
                 if(htr.History_Premise_Number__c == clan){
                     String soqlhtr = API_Utils.getCreatableFieldsSOQL('RDS_History_Tracking__c', 'id=\''+htr.Id+'\'');    
                     RDS_History_Tracking__c htrRec = (RDS_History_Tracking__c)Database.query(soqlhtr);
                     RDS_History_Tracking__c newHTR = htrRec.clone(false,true,true,true);
                     newHTR.RDSCircuitVLANDetails__c = macdCVLANMap.get(htr.History_Premise_Number__c).Id;
                     newHTR.MACD_Type__c = MACDConstant.C;
                     histToClone.add(newHTR);
                 }
             }
         }
     }
     
     if(histToClone.size()>0){
         try{
            insert histToClone;
         }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
     }
     
     if(v4FamShortList.size()>0){
         for(String clan :macdCVLANMap.keyset()){
             for(RDS_V4_Family_Data__c v4r : v4FamShortList){
                 if(v4r.V4_Family_Premise_Number__c == clan){
                     String soqlv4r = API_Utils.getCreatableFieldsSOQL('RDS_V4_Family_Data__c', 'id=\''+v4r.Id+'\'');    
                     RDS_V4_Family_Data__c v4rRec = (RDS_V4_Family_Data__c)Database.query(soqlv4r);
                     RDS_V4_Family_Data__c newv4R = v4rRec.clone(false,true,true,true);
                     newv4R.RDS_Circuit_and_VLAN_Details_V4__c = macdCVLANMap.get(v4r.V4_Family_Premise_Number__c).Id;
                     newv4R.MACD_Type__c = MACDConstant.C;
                     newv4R.Cloned_From__c = v4r.Id;
                     v4FamShortListToClone.add(newv4R);
                 }
             }
         }
     }
     
     if(v4FamShortListToClone.size()>0){
         try{
            insert v4FamShortListToClone;
          }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
     }
     
     if(v6FamShortList.size()>0){
         for(String clan :macdCVLANMap.keyset()){
             for(V6_Family_Data__c v6r : v6FamShortList){
                 if(v6r.V6_Family_Premise_Number__c == clan){
                     String soqlv6r = API_Utils.getCreatableFieldsSOQL('V6_Family_Data__c', 'id=\''+v6r.Id+'\'');    
                     V6_Family_Data__c v6rRec = (V6_Family_Data__c)Database.query(soqlv6r);
                     V6_Family_Data__c newv6R = v6rRec.clone(false,true,true,true);
                     newv6R.RDS_Circuit_and_VLAN_Details_V6__c = macdCVLANMap.get(v6r.V6_Family_Premise_Number__c).Id;
                     newv6R.MACD_Type__c = MACDConstant.C;
                     newv6R.Cloned_From__c = v6r.Id;
                     v6FamShortListToClone.add(newv6R);
                 }
             }
         }
     }
     
     if(v6FamShortListToClone.size()>0){
         try{
            insert v6FamShortListToClone;
         }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
     }
     
     if(v4FamLongList.size()>0 || v4FamShortList.size()>0){
     orgV4Family = [Select Id, V4_Family_Premise_Number__c, Cloned_From__c from RDS_V4_Family_Data__c where (Id =: v4FamLongList OR Id =: v4FamShortList)];
     }
     if(v6FamLongList.size()>0 || v6FamShortList.size()>0){
     orgV6Family = [Select Id, V6_Family_Premise_Number__c, Cloned_From__c from V6_Family_Data__c where (Id =: v6FamLongList OR Id =: v6FamShortList)];
     }
     if(v4FamLongListToClone.size()>0 || v4FamShortListToClone.size()>0){
     clonedV4Family = [Select Id, V4_Family_Premise_Number__c, Cloned_From__c from RDS_V4_Family_Data__c where (Id =: v4FamLongListToClone OR Id =: v4FamShortListToClone)];
     }
     if(v6FamLongListToClone.size()>0 || v6FamShortListToClone.size()>0){
     clonedV6Family = [Select Id, V6_Family_Premise_Number__c, Cloned_From__c from V6_Family_Data__c where (Id =: v6FamLongListToClone OR Id =: v6FamShortListToClone)];
     }
     if(orgV4Family.size()>0){
     v4LanList = [Select Id, RDS_V4_Family_Data__c from RDS_V4_LAN_IP_Address__c where RDS_V4_Family_Data__c =: orgV4Family];
     }       
     if(orgV6Family.size()>0){
     v6LanList = [Select Id, RDS_V6_Family_Data__c from RDS_V6_LAN_IP_Address__c where RDS_V6_Family_Data__c =: orgV6Family];    
     }

    if(orgV4Family.size()>0){
         if(clonedV4Family.size()>0){
             if(v4LanList.size()>0){
                for(RDS_V4_Family_Data__c v4fOld : orgV4Family){
                    for(RDS_V4_Family_Data__c Cv4f : clonedV4Family){
                         for(RDS_V4_LAN_IP_Address__c v4f :v4LanList){
                             if(v4f.RDS_V4_Family_Data__c == v4fOld.Id && Cv4f.Cloned_From__c == v4fOld.Id && Cv4f.V4_Family_Premise_Number__c == v4fOld.V4_Family_Premise_Number__c){
                                 String soqlv4f = API_Utils.getCreatableFieldsSOQL('RDS_V4_LAN_IP_Address__c', 'id=\''+v4f.Id+'\'');    
                                 RDS_V4_LAN_IP_Address__c v4fam = (RDS_V4_LAN_IP_Address__c)Database.query(soqlv4f);
                                 RDS_V4_LAN_IP_Address__c newv4f = v4fam.clone(false,true,true,true);
                                 newv4f.RDS_V4_Family_Data__c = Cv4f.Id;
                                 newv4f.MACD_Type__c = MACDConstant.C;
                                 v4LanListToClone.add(newv4f);
                             }
                         }
                    }
                }
             }
         }
    }
     
     if(v4LanListToClone.size()>0){
         try{
            insert v4LanListToClone;
         }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
     }
     
     if(orgV6Family.size()>0){
         if(clonedV6Family.size()>0){
             if(v6LanList.size()>0){
                for(V6_Family_Data__c v6fOld : orgV6Family){
                    for(V6_Family_Data__c Cv6f : clonedV6Family){
                         for(RDS_V6_LAN_IP_Address__c v6f :v6LanList){
                             if(v6f.RDS_V6_Family_Data__c == v6fOld.Id && Cv6f.Cloned_From__c == v6fOld.Id && Cv6f.V6_Family_Premise_Number__c == v6fOld.V6_Family_Premise_Number__c){
                                 String soqlv6f = API_Utils.getCreatableFieldsSOQL('RDS_V6_LAN_IP_Address__c', 'id=\''+v6f.Id+'\'');    
                                 RDS_V6_LAN_IP_Address__c v6fam = (RDS_V6_LAN_IP_Address__c)Database.query(soqlv6f);
                                 RDS_V6_LAN_IP_Address__c newv6f = v6fam.clone(false,true,true,true);
                                 newv6f.RDS_V6_Family_Data__c = Cv6f.Id;
                                 newv6f.MACD_Type__c = MACDConstant.C;
                                 v6LanListToClone.add(newv6f);
                             }
                         }
                    }
                }
             }
         }
    }
     
     if(v6LanListToClone.size()>0){
         try{
            insert v6LanListToClone;
        }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
     }
     
     if((stat == MACDConstant.PORTACCESSSPEEDCHANGE&& isInterfaceChange == false) || stat == MACDConstant.ADD || stat == MACDConstant.DISCONNECT){
         Deal_Hash__c dh = [Select Id, RDS_object_status__c, Is_MACDReviewComplete__c from Deal_Hash__c where Id =: dealHashId limit 1];
         if(dh != null){
             dh.RDS_object_status__c = MACDConstant.REVIEWCOMPLETED;
             dh.Is_MACDReviewComplete__c = true;
             dh.RDS_Version_Select__c = String.valueOf(version);
                 try{
                    update dh;
                }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
         }
         if(latetestOppty != null){
             if(!isInterfaceChange){
             latetestOppty.Review_Check__c = true;
             latetestOppty.MACD_Review_Complete__c = true;
             latetestOppty.MACD_RDS_Review_Completed_Status__c = MACDConstant.SUCCESS;
             latetestOppty.MACD_RDS_Review_Complete_LastTimeStamp__c = DateTime.Now();
             }
             latetestOppty.RDS_Received_Status__c=MACDConstant.SUCCESS;
             latetestOppty.RDS_Received_Last_Time_Stamp__c = DateTime.Now();
             latetestOppty.RDS_Completion_Date__c = Date.Today();
             latetestOppty.RDS_Percent_Complete__c = Decimal.valueof(100);
             latetestOppty.RDS_Complete__c = True;
                try{
                    update latetestOppty;
                 }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
         }
     }
     
     // Added Condition For UBB Add 
     if(stat == MACDConstant.UBBADD1 || stat == MACDConstant.UBBREMOVE1 || stat == MACDConstant.UBBCHANGE1 || stat == MACDConstant.COSADD || stat == MACDConstant.COSREMOVE){
         Deal_Hash__c dh = [Select Id, RDS_object_status__c, Is_MACDReviewComplete__c from Deal_Hash__c where Id =: dealHashId limit 1];
         if(dh != null){
             dh.RDS_object_status__c = MACDConstant.REVIEWCOMPLETED;
             dh.Is_MACDReviewComplete__c = true;
             dh.RDS_Version_Select__c = String.valueOf(version);
                 try{
                    update dh;
                 }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
         }
         if(latetestOppty != null){
            
             latetestOppty.MACD_RDS_Review_Completed_Status__c = SpecialCharacterBuyflowConstant.CONCAT;
             latetestOppty.MACD_RDS_Review_Complete_LastTimeStamp__c = null;
             latetestOppty.RDS_Received_Status__c=MACDConstant.SUCCESS;
             latetestOppty.RDS_Received_Last_Time_Stamp__c = DateTime.Now();
             latetestOppty.RDS_Completion_Date__c = Date.Today();
             latetestOppty.RDS_Percent_Complete__c = Decimal.valueof(100);
             latetestOppty.RDS_Complete__c = True;
                try{
                    update latetestOppty;
                 }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
         }
         If(stat == MACDConstant.DISCONNECT){
         API_MACDCVLAN_CHANGE.updateRDSPremise(vlanToClone);}
     }
    // End Condition For UBB Add 
         
     }  
/* 
 Name: updateRDSPremise
 Description: 
 */ 
     public static void updateRDSPremise(List<VLAN_Information__c> updatedObjects){
        List<VLAN_Information__c> vlanList = updatedObjects;
        Set<Id> vlanIds= new Set<Id>();
        Set<Id> cvlanIds = new Set<Id>();
        List<RDS_Premise_Details__c> premiseList = new List<RDS_Premise_Details__c>();
        Map<Id,Integer> premiseNumberMap = new Map<Id,Integer>();
        for(integer i=0;i<vlanList.size();i++){
            if(vlanList[i].VLAN_Status__c == MACDConstant.PENDINGDISCONNECT){
                vlanIds.add(vlanList[i].Id);
                cvlanIds.add(vlanList[i].Circuit_and_VLAN_Details__c);
            }
        }
        for(Circuit_and_VLAN_Details__c cv: [Select Id, Premise__c, Premise_Number__c, (Select Id, VLAN_Status__c from VLAN_Information__r where (VLAN_Status__c  = 'Pending Disconnect')) from Circuit_and_VLAN_Details__c where Id IN: cvlanIds]){
            premiseNumberMap.put(cv.Premise__c,cv.VLAN_Information__r.size());
        }
        for(RDS_Premise_Details__c prem:[select Id,USO_Number_of_USOS__c from RDS_Premise_Details__c where Id IN: premiseNumberMap.keySet()]){
            if(premiseNumberMap.containsKey(prem.Id)){
                prem.USO_Number_of_USOS__c = premiseNumberMap.get(prem.Id);
                premiseList.add(prem);
            }
        }
        
        if(premiseList.size()>0){
            update premiseList;
        }
    }
}