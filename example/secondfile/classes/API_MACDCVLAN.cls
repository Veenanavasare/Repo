/*
     Component Name :API_MACDCVLAN 
     Requirement/User Story Number : US306463
     Requirement Description: Class to for cloning objects under CVLAN.
     Component Author:Accenture IDC
     Created Date: 19th October 2014 
     Version:1.0
     Last Modified By: Accenture IDC
    */
    
/* Method to create Related objetcs under CVLAN when MACD disconnect is performed */ 
global class API_MACDCVLAN { 
@future
     public static void createChildRecordsForMACDCVLAN(Set<Id> macdCVLANIdSet, Set<Id> masterCVLANIdSet, String dealHashId, String stat, Id newMACDOptyId, Decimal version){
     Map<String,Circuit_and_VLAN_Details__c> macdCVLANMap = new Map<String,Circuit_and_VLAN_Details__c>();
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
    
    for(Circuit_and_VLAN_Details__c cv: [Select Id, CVLAN_Premise_Number__c,Premise__r.Disconnect_Type__c from Circuit_and_VLAN_Details__c where Id =: macdCVLANIdSet]){
             macdCVLANMap.put(cv.CVLAN_Premise_Number__c,cv);        // map of CVLAN records that were created because of MACD Disconnect
    }
     
    if(masterCVLANIdSet.size()>0){
         accCktIdList = [Select Id, RDS_Premise_Number__c, Circuit_and_VLAN_Details__c  from RDS_Access_Circuit_ID__c where Circuit_and_VLAN_Details__c =: masterCVLANIdSet];
         albIdList = [Select Id, ALB_Premise_Number__c, Circuit_and_VLAN_Details__c  from RDS_ALB_Access_Circuits__c where Circuit_and_VLAN_Details__c =: masterCVLANIdSet];
         rdsSWIPCon = [Select Id, RDS_SWIP_Contact_Premise_Number__c, Circuit_and_VLAN_Details__c  from RDS_SWIP_Contacts__c where Circuit_and_VLAN_Details__c =: masterCVLANIdSet];
         vlanList = [Select Id, VLAN_Premise_Number__c, Circuit_and_VLAN_Details__c  from VLAN_Information__c where Circuit_and_VLAN_Details__c =: masterCVLANIdSet];
         vpnList = [Select Id, VPN_Premise_Number__c, Circuit_and_VLAN_Details__c  from RDS_VPN_Data__c where Circuit_and_VLAN_Details__c =: masterCVLANIdSet];
         histList = [Select Id, History_Premise_Number__c, RDSCircuitVLANDetails__c from RDS_History_Tracking__c where RDSCircuitVLANDetails__c =: masterCVLANIdSet];
         v4FamShortList = [Select Id, V4_Family_Premise_Number__c, RDS_Circuit_and_VLAN_Details_V4__c, Cloned_From__c from RDS_V4_Family_Data__c where RDS_Circuit_and_VLAN_Details_V4__c =: masterCVLANIdSet];
         v6FamShortList = [Select Id, V6_Family_Premise_Number__c, RDS_Circuit_and_VLAN_Details_V6__c, Cloned_From__c from V6_Family_Data__c where RDS_Circuit_and_VLAN_Details_V6__c =: masterCVLANIdSet];       
     }
     Circuit_and_VLAN_Details__c myCVDetail;
     
     if(accCktIdList.size()>0){
     accBillList = [Select Id, RDS_Access_Circuit_ID__c from RDS_Access_Billing_Element_Details__c where RDS_Access_Circuit_ID__c =: accCktIdList];
         for(String clan :macdCVLANMap.keyset()){
             myCVDetail = macdCVLANMap.get(clan);
             for(RDS_Access_Circuit_ID__c ackt :accCktIdList){
                 if(ackt.RDS_Premise_Number__c == clan){
                     String soqlCKT = API_Utils.getCreatableFieldsSOQL('RDS_Access_Circuit_ID__c', 'id=\''+ackt.Id+'\'');    
                     RDS_Access_Circuit_ID__c ckt = (RDS_Access_Circuit_ID__c )Database.query(soqlCKT);
                     RDS_Access_Circuit_ID__c newCKT = ckt.clone(false,true,true,true);
                     newCKT.Circuit_and_VLAN_Details__c = macdCVLANMap.get(ackt.RDS_Premise_Number__c).Id;
                     newCKT.MACD_Type__c = 'D';
                     newCKT.Master_of_Clone__c = ackt.Id;
                     if(myCVDetail.Premise__r.Disconnect_Type__c != null && myCVDetail.Premise__r.Disconnect_Type__c == ATTConstants.HD){
                         //Start of changes to blank out the uso number for hard disconnect
                         newCKT.USO_Number__c = '';
                         //End of changes
                     }
                     accCKTToClone.add(newCkT);
                 }
             }
         }
     }
     
     if(accCKTToClone.size()>0){
         try{
            insert accCKTToClone;
         } catch(DMLException e){
            System.debug('Exception here:'+ e);
         }
     }
     
     List<RDS_Access_Circuit_ID__c> clonedACKT = [Select Id, Master_of_Clone__c, RDS_Premise_Number__c from RDS_Access_Circuit_ID__c where Id =: accCKTToClone];
     
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
                                 newbillA.MACD_Type__c = 'D';
                                 accBillToCloneList.add(newbillA);
                             }
                         }
                    }
                }
             }
         }
    }
    System.debug('----Access Billing to Clone----'+accBillToCloneList);
     if(accBillToCloneList.size()>0){
         try{
            insert accBillToCloneList;
         } catch(DMLException e){
            System.debug('Exception here:'+ e);
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
                     newALB.MACD_Type__c = 'D';
                     albToClone.add(newALB);
                 }
             }
         }
     }
     
     if(albToClone.size()>0){
         try{
            insert albToClone;
         } catch(DMLException e){
            System.debug('Exception here:'+ e);
         }
     }
     
     if(vlanList.size()>0){
     v4FamLongList = [Select Id, V4_Family_Premise_Number__c, RDS_VLAN_Information_V4__c, Cloned_From__c from RDS_V4_Family_Data__c where RDS_VLAN_Information_V4__c =: vlanList];
     v6FamLongList = [Select Id, V6_Family_Premise_Number__c, RDS_VLAN_Information__c, Cloned_From__c from V6_Family_Data__c where RDS_VLAN_Information__c =: vlanList];    
         for(String clan :macdCVLANMap.keyset()){
             myCVDetail = macdCVLANMap.get(clan);
             for(VLAN_Information__c vl :vlanList){
                 if(vl.VLAN_Premise_Number__c == clan){
                     String soqlvl = API_Utils.getCreatableFieldsSOQL('VLAN_Information__c', 'id=\''+vl.Id+'\'');    
                     VLAN_Information__c vlRec = (VLAN_Information__c)Database.query(soqlvl);
                     VLAN_Information__c newvl = vlRec.clone(false,true,true,true);
                     newvl.Circuit_and_VLAN_Details__c = macdCVLANMap.get(vl.VLAN_Premise_Number__c).Id;
                     newvl.MACD_Type__c = 'D';
                     if(myCVDetail.Premise__r != null && myCVDetail.Premise__r.Disconnect_Type__c != null && myCVDetail.Premise__r.Disconnect_Type__c == ATTConstants.HD ){
                         //Start of changes to blank out the uso number for har disconnect
                         newvl.USO_Number__c = '';
                         //End of changes
                     }
                     vlanToClone.add(newvl);
                 }
             }
         }
     }
     
     if(vlanToClone.size()>0){
         try{
            insert vlanToClone;
         } catch(DMLException e){
            System.debug('Exception here:'+ e);
         }
     }
     
     List<VLAN_Information__c> clonedVLAN = [Select Id, VLAN_Premise_Number__c from VLAN_Information__c where Id =: vlanToClone  LIMIT : limits.getLimitQueryRows()];
     
     if(vlanList.size()>0){
         if(v4FamLongList.size()>0){
             if(clonedVLAN.size()>0){
                for(VLAN_Information__c rvl : vlanList){
                    for(VLAN_Information__c Cvl : clonedVLAN){
                         for(RDS_V4_Family_Data__c vl :v4FamLongList){
                             if(vl.RDS_VLAN_Information_V4__c == rvl.Id && Cvl.VLAN_Premise_Number__c == rvl.VLAN_Premise_Number__c){
                                 String soqlvl = API_Utils.getCreatableFieldsSOQL('RDS_V4_Family_Data__c', 'id=\''+vl.Id+'\'');    
                                 RDS_V4_Family_Data__c vln = (RDS_V4_Family_Data__c)Database.query(soqlvl);
                                 RDS_V4_Family_Data__c newVLN = vln.clone(false,true,true,true);
                                 newVLN.RDS_VLAN_Information_V4__c = Cvl.Id;
                                 newVLN.MACD_Type__c = 'D';
                                 newVLN.Cloned_From__c = vl.Id;
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
         } catch(DMLException e){
            System.debug('Exception here:'+ e);
         }
     } 
     
     if(vlanList.size()>0){
         if(v6FamLongList.size()>0){
             if(clonedVLAN.size()>0){
                for(VLAN_Information__c rvl6 : vlanList){
                    for(VLAN_Information__c Cvl6 : clonedVLAN){
                         for(V6_Family_Data__c vl6 :v6FamLongList){
                             if(vl6.RDS_VLAN_Information__c == rvl6.Id && Cvl6.VLAN_Premise_Number__c == rvl6.VLAN_Premise_Number__c){
                                 String soqlvl6 = API_Utils.getCreatableFieldsSOQL('V6_Family_Data__c', 'id=\''+vl6.Id+'\'');    
                                 V6_Family_Data__c vln6 = (V6_Family_Data__c)Database.query(soqlvl6);
                                 V6_Family_Data__c newVLN6 = vln6.clone(false,true,true,true);
                                 newVLN6.RDS_VLAN_Information__c = Cvl6.Id;
                                 newVLN6.MACD_Type__c = 'D';
                                 newVLN6.Cloned_From__c = vl6.Id;
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
         } catch(DMLException e){
            System.debug('Exception here:'+ e);
         }
     }
     
     if(vpnList.size()>0){
     v4List = [Select Id, RDS_VPN_Data_V4__c from RDS_Mutlicast_V4__c where RDS_VPN_Data_V4__c =: vpnList  LIMIT : limits.getLimitQueryRows()];
     v6List = [Select Id, RDS_VPN_Data_V6__c from RDS_Mutlicast_V6__c where RDS_VPN_Data_V6__c =: vpnList  LIMIT : limits.getLimitQueryRows()];
         for(String clan :macdCVLANMap.keyset()){
             for(RDS_VPN_Data__c vp :vpnList){
                 if(vp.VPN_Premise_Number__c == clan){
                     String soqlvp = API_Utils.getCreatableFieldsSOQL('RDS_VPN_Data__c', 'id=\''+vp.Id+'\'');    
                     RDS_VPN_Data__c vpRec = (RDS_VPN_Data__c)Database.query(soqlvp);
                     RDS_VPN_Data__c newvp = vpRec.clone(false,true,true,true);
                     newvp.Circuit_and_VLAN_Details__c = macdCVLANMap.get(vp.VPN_Premise_Number__c).Id;
                     newvp.MACD_Type__c = 'D';
                     vpnToClone.add(newvp);
                 }
             }
         }
     }
     
     if(vpnToClone.size()>0){
         try{
            insert vpnToClone;
         } catch(DMLException e){
            System.debug('Exception here:'+ e);
         }
     }
     
     List<RDS_VPN_Data__c> clonedVPN = [Select Id, VPN_Premise_Number__c from RDS_VPN_Data__c where Id =: vpnToClone  LIMIT : limits.getLimitQueryRows()];
     
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
                                 newvp4.MACD_Type__c = 'D';
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
         } catch(DMLException e){
            System.debug('Exception here:'+ e);
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
                                 newvp6.MACD_Type__c = 'D';
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
         } catch(DMLException e){
            System.debug('Exception here:'+ e);
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
                     newRCon.MACD_Type__c = 'D';
                     rdsSWIPConToClone.add(newRCon);
                 }
             }
         }
     }
     
     if(rdsSWIPConToClone.size()>0){
         try{
            insert rdsSWIPConToClone;
         } catch(DMLException e){
            System.debug('Exception here:'+ e);
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
                     newHTR.MACD_Type__c = 'D';
                     histToClone.add(newHTR);
                 }
             }
         }
     }
     
     if(histToClone.size()>0){
         try{
            insert histToClone;
         } catch(DMLException e){
            System.debug('Exception here:'+ e);
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
                     newv4R.MACD_Type__c = 'D';
                     newv4R.Cloned_From__c = v4r.Id;
                     v4FamShortListToClone.add(newv4R);
                 }
             }
         }
     }
     
     if(v4FamShortListToClone.size()>0){
         try{
            insert v4FamShortListToClone;
         } catch(DMLException e){
            System.debug('Exception here:'+ e);
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
                     newv6R.MACD_Type__c = 'D';
                     newv6R.Cloned_From__c = v6r.Id;
                     v6FamShortListToClone.add(newv6R);
                 }
             }
         }
     }
     
     if(v6FamShortListToClone.size()>0){
         try{
            insert v6FamShortListToClone;
         } catch(DMLException e){
            System.debug('Exception here:'+ e);
         }
     }
     
     if(v4FamLongList.size()>0 || v4FamShortList.size()>0){
     	orgV4Family = [Select Id, V4_Family_Premise_Number__c, Cloned_From__c from RDS_V4_Family_Data__c where (Id =: v4FamLongList OR Id =: v4FamShortList)];
     //System.debug('---Original V4 Fams----'+orgV4Family );
     }
     if(v6FamLongList.size()>0 || v6FamShortList.size()>0){
     	orgV6Family = [Select Id, V6_Family_Premise_Number__c, Cloned_From__c from V6_Family_Data__c where (Id =: v6FamLongList OR Id =: v6FamShortList)];
     //System.debug('---Original V6 Fams----'+orgV6Family );
     }
     if(v4FamLongListToClone.size()>0 || v4FamShortListToClone.size()>0){
     	clonedV4Family = [Select Id, V4_Family_Premise_Number__c, Cloned_From__c from RDS_V4_Family_Data__c where (Id =: v4FamLongListToClone OR Id =: v4FamShortListToClone)];
     //System.debug('---Cloned V4 Fams----'+clonedV4Family);
     }
     if(v6FamLongListToClone.size()>0 || v6FamShortListToClone.size()>0){
     	clonedV6Family = [Select Id, V6_Family_Premise_Number__c, Cloned_From__c from V6_Family_Data__c where (Id =: v6FamLongListToClone OR Id =: v6FamShortListToClone)];
     //System.debug('---Cloned V6 Fams----'+clonedV6Family);
     }
     if(orgV4Family.size()>0){
     	v4LanList = [Select Id, RDS_V4_Family_Data__c from RDS_V4_LAN_IP_Address__c where RDS_V4_Family_Data__c =: orgV4Family];
     //System.debug('---Fresh V4 Lans----'+v4LanList);    
     }       
     if(orgV6Family.size()>0){
     	v6LanList = [Select Id, RDS_V6_Family_Data__c from RDS_V6_LAN_IP_Address__c where RDS_V6_Family_Data__c =: orgV6Family];    
     //System.debug('---Fresh V6 Lans----'+v6LanList); 
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
                                 newv4f.MACD_Type__c = 'D';
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
            //System.debug('----V4 LAN----'+v4LanListToClone);
         } catch(DMLException e){
            System.debug('Exception here:'+ e);
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
                                 newv6f.MACD_Type__c = 'D';
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
           // System.debug('---V6 LAN----'+v6LanListToClone);
         } catch(DMLException e){
            System.debug('Exception here:'+ e);
         }
     }
     
     if(stat == ATTConstants.HARD_STAT){
        Deal_Hash__c dh = [Select Id, RDS_object_status__c, Is_MACDReviewComplete__c from Deal_Hash__c where Id =: dealHashId limit 1];
         if(dh != null){
         //System.debug('---DH MACD Update---'+dh);
             dh.RDS_object_status__c = Constant.Api_Macd_VlanChange_ReviewCompleted;
             dh.Is_MACDReviewComplete__c = true;
             dh.RDS_Version_Select__c = String.valueOf(version);
                 try{
                 //system.debug('---DH MACD Update---'+dh);
                    update dh;
                 } catch(DMLException e){
                    System.debug('Exception here:'+ e);
                 }
         }
        Opportunity latetestOppty = [Select Id, Review_Check__c, MACD_Review_Complete__c, MACD_RDS_Review_Completed_Status__c, MACD_RDS_Review_Complete_LastTimeStamp__c from Opportunity where Id=: newMACDOptyId limit 1];
         if(latetestOppty != null){
//         System.debug('---Oppty MACD Update---'+latetestOppty);
             latetestOppty.Review_Check__c = true;
             latetestOppty.MACD_Review_Complete__c = true;
             latetestOppty.MACD_RDS_Review_Completed_Status__c = Constant.macdRDSAVPNController_Success;
             latetestOppty.MACD_RDS_Review_Complete_LastTimeStamp__c = DateTime.Now();
                try{
  //              System.debug('---Oppty MACD Update---'+latetestOppty);
                    update latetestOppty;
                 } catch(DMLException e){
                    System.debug('Exception here:'+ e);
                 }
         }
     }
     
     }  
}