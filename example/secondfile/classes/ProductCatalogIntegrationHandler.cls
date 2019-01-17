/************************************************************************************* 
Apex Class Name     : ProductCatalogIntegrationHandler
Version             : 1.0 
Created Date        : 01-08-2018
Function            : This class is used for Product Catalog Integration Logic                  
*************************************************************************************/
public class ProductCatalogIntegrationHandler{  
    
    /*Method which returns Map of Configuration Data from APEX Product Catalog Ids*/
    public map<String,String> getDatafromCatalogIds(map<String,String> catalogIdMap){
        system.debug('@@@APEX Catalog Ids: '+catalogIdMap);
        Map<String,APEX_Product_Catalog__c> catalogRecordDataMap = new Map<String,APEX_Product_Catalog__c>();
        for(APEX_Product_Catalog__c catalog : [SELECT Access_Architecture__c,Access_Needed__c,Access_Type__c,Active__c,BVoip_Ip_Id__c,BVoip_Line_Features__c,BVoip_Local__c,BVoip_Truck_Calling__c,Compatible_Access_ID__c,Compatible_DNS_ID__c,Compatible_Install_ID__c,Compatible_IPFlex_ID__c,Compatible_MBC__c,Compatible_Service_Code__c,Concurrent_Calls_Max__c,Concurrent_Calls_Min__c,Connectivity_Type__c,CreatedById,CreatedDate,Default_Access_Id__c,Default_Cos_ID__c,Default_Hicap_ID__c,Default_Install__c,Description__c,Dw_Speed__c,Flatrate_Indicator__c,Hicap_Indicator__c,Id,IsDeleted,Managed_Service__c,MBC_Description__c,Name,OwnerId,Product_Abbrevation__c,RecordTypeId,RecordType.Name,Service_Code__c,Service_ID__c,Service_Name__c,Service_Segment__c,Service_Type__c,Speed_Name__c,Speed_Type__c,Speed_Unit__c,Speed_Value__c,SystemModstamp,Transport_Type__c,Up_Speed__c,Version__c,Vlan__c FROM APEX_Product_Catalog__c where Name in:catalogIdMap.keySet() AND Active__c=true]){
            catalogRecordDataMap.put(catalog.Name,catalog);            
        }
        System.debug('@@@APEX Catalog Data: '+catalogRecordDataMap);
        map<String,String> portSpeedPLAVPN = new Map<String, String>{'1.544 Mbps'=>'T1 (1.544 Mbps)','3.088 Mbps'=>'2xT1 (3.088 Mbps)','4.632 Mbps'=>'3xT1 (4.632 Mbps)','6.176 Mbps'=>'4xT1 (6.176 Mbps)','7.720 Mbps'=>'5xT1 (7.720 Mbps)','9.264 Mbps'=>'6xT1 (9.264 Mbps)','10.808 Mbps'=>'7xT1 (10.808 Mbps)','12.352 Mbps'=>'8xT1 (12.352 Mbps)'};
        map<String,String> portSpeedPLMIS = new Map<String, String>{'1.544 Mbps'=>'T1 (1.544 Mbps)','3.088 Mbps'=>'2xT1 (3 Mbps)','4.632 Mbps'=>'3xT1 (4.5 Mbps)','6.176 Mbps'=>'4xT1 (6 Mbps)','7.720 Mbps'=>'5xT1 (7.5 Mbps)','9.264 Mbps'=>'6xT1 (9 Mbps)','10.808 Mbps'=>'7xT1 (10.5 Mbps)','12.352 Mbps'=>'8xT1 (12 Mbps)'};
        map<String,String> accessSpeedPL = new Map<String, String>{'(1.544'=>'(1.544','(3.088'=>'(3','(4.632'=>'(4.5','(6.176'=>'(6','(7.720'=>'(7.5','(9.264'=>'(9','(10.808'=>'(10.5','(12.352'=>'(12'};
        map<String,String> catalogDataMap = new map<String,String>();              
        for(String catalogID : catalogIdMap.keySet()){
            if(catalogRecordDataMap.containsKey(catalogID)){
                if((catalogRecordDataMap.get(catalogID).RecordType.Name).equalsIgnoreCase('Port Catalog')){
                    catalogDataMap.put('Port_Catalog_Id__c',catalogID);
                    if(catalogRecordDataMap.get(catalogID).Service_Code__c == 'ADI'){
                        catalogDataMap.put('ProductName','MIS');
                        if((catalogRecordDataMap.get(catalogID).Transport_Type__c).containsIgnoreCase('ETHERNET')){
                            catalogDataMap.put('Port_Speed_MIS__c', catalogRecordDataMap.get(catalogID).Speed_Value__c+' '+catalogRecordDataMap.get(catalogID).Speed_Unit__c);
                            catalogDataMap.put('Port_Type_MIS__c','Switched Ethernet');
                            if((catalogRecordDataMap.get(catalogID).Connectivity_Type__c).equalsIgnoreCase('ELECTRICAL')!= null && (catalogRecordDataMap.get(catalogID).Connectivity_Type__c).containsIgnoreCase('ELECTRICAL')){
                                catalogDataMap.put('Interface_Type__c','Electrical - 100 Base TX');
                            }
                            else if((catalogRecordDataMap.get(catalogID).Connectivity_Type__c).equalsIgnoreCase('OPTICAL')!= null && (catalogRecordDataMap.get(catalogID).Connectivity_Type__c).containsIgnoreCase('OPTICAL')){
                                catalogDataMap.put('Interface_Type__c','Optical Single Mode - 1000 Base LX');
                            }
                        }
                        else if((catalogRecordDataMap.get(catalogID).Transport_Type__c).containsIgnoreCase('PRIVATELINE')){
                            String portSpeed = portSpeedPLMIS.get(catalogRecordDataMap.get(catalogID).Speed_Value__c+' '+catalogRecordDataMap.get(catalogID).Speed_Unit__c);
                            catalogDataMap.put('Port_Speed_MIS__c', portSpeed);
                            catalogDataMap.put('Port_Type_MIS__c','Private Line');
                        }
                        if(catalogRecordDataMap.get(catalogID).Managed_Service__c == true){
                            catalogDataMap.put('Managed_Router__c','True');
                        }
                        System.debug('@@@PORT - MIS Logic - catalogDataMap: '+catalogDataMap);                        
                    }
                    else if(catalogRecordDataMap.get(catalogID).Service_Code__c == 'AVPN'){
                        catalogDataMap.put('ProductName','AVPN');
                        if((catalogRecordDataMap.get(catalogID).Transport_Type__c).containsIgnoreCase('ETHERNET')){
                            catalogDataMap.put('Port_Speed_AVPN__c', catalogRecordDataMap.get(catalogID).Speed_Value__c+' '+catalogRecordDataMap.get(catalogID).Speed_Unit__c);
                            catalogDataMap.put('Port_Type_AVPN__c','Switched Ethernet');
                            if((catalogRecordDataMap.get(catalogID).Connectivity_Type__c).equalsIgnoreCase('ELECTRICAL')!= null &&(catalogRecordDataMap.get(catalogID).Connectivity_Type__c).containsIgnoreCase('ELECTRICAL')){
                                catalogDataMap.put('Interface_Type_AVPN__c','Electrical - 100 Base TX');
                            }else if((catalogRecordDataMap.get(catalogID).Connectivity_Type__c).equalsIgnoreCase('OPTICAL')!= null &&(catalogRecordDataMap.get(catalogID).Connectivity_Type__c).containsIgnoreCase('OPTICAL')){
                                catalogDataMap.put('Interface_Type_AVPN__c','Optical Single Mode - 1000 Base LX');
                            } 
                        }
                        else if((catalogRecordDataMap.get(catalogID).Transport_Type__c).containsIgnoreCase('PRIVATELINE')){
                            String portSpeed = portSpeedPLAVPN.get(catalogRecordDataMap.get(catalogID).Speed_Value__c+' '+catalogRecordDataMap.get(catalogID).Speed_Unit__c);
                            catalogDataMap.put('Port_Speed_AVPN__c', portSpeed);
                            catalogDataMap.put('Port_Type_AVPN__c','Private Line');
                        } 
                        System.debug('@@@PORT - AVPN Logic - catalogDataMap:'+catalogDataMap);
                    }                    
                }
                else if((catalogRecordDataMap.get(catalogID).RecordType.Name).equalsIgnoreCase('Access Catalog')){ 
                    catalogDataMap.put('Access_Catalog_Id__c',catalogID);                   
                    if((catalogRecordDataMap.get(catalogID).Transport_Type__c).containsIgnoreCase('ETHERNET')){
                        catalogDataMap.put('Access_Type__c','Switched Ethernet');
                        catalogDataMap.put('Access_Type_AVPN__c','Switched Ethernet');
                        catalogDataMap.put('Access_Speed_MIS__c', catalogRecordDataMap.get(catalogID).Speed_Value__c+' '+catalogRecordDataMap.get(catalogID).Speed_Unit__c);
                        catalogDataMap.put('Access_Speed_AVPN__c', catalogRecordDataMap.get(catalogID).Speed_Value__c+' '+catalogRecordDataMap.get(catalogID).Speed_Unit__c);
                        System.debug('@@@ACCESS - SWITCHED ETHERNET - catalogDataMap:'+catalogDataMap);
                    }
                    else{
                        catalogDataMap.put('Access_Type_AVPN__c','Private Line');
                        catalogDataMap.put('Access_Type__c','Private Line');
                        List<String> speedList= catalogRecordDataMap.get(catalogID).Speed_Name__c.split(' ');
                        catalogDataMap.put('Access_Speed_AVPN__c',speedList[1]+' '+speedList[2]+' '+speedList[3]);
                        if(accessSpeedPL.containsKey(speedList[2])){
                            speedList[2] = accessSpeedPL.get(speedList[2]);
                        }
                        catalogDataMap.put('Access_Speed_MIS__c',speedList[1]+' '+speedList[2]+' '+speedList[3]);
                        System.debug('@@@ACCESS - PRIVATE LINE - catalogDataMap:'+catalogDataMap);
                    }                   
                }
                else if((catalogRecordDataMap.get(catalogID).RecordType.Name).containsIgnoreCase('COS Catalog') && (catalogRecordDataMap.get(catalogID).RecordType.Name).equalsIgnoreCase('COS Catalog')!= null &&(catalogRecordDataMap.get(catalogID).RecordType.Name).equalsIgnoreCase('COS Catalog')){
                    catalogDataMap.put('CoS__c','True');
                    catalogDataMap.put('COS_catalog_Id__c',catalogID);
                    System.debug('@@@COS - catalogDataMap:'+catalogDataMap);                         
                }
                else if((catalogRecordDataMap.get(catalogID).RecordType.Name).equalsIgnoreCase('Installation Catalog')){
                    if(catalogRecordDataMap.get(catalogID).Description__c == 'On-Site Install'){
                        catalogDataMap.put('Install_Option_MIS__c','Onsite Install');
                        catalogDataMap.put('Install_Option_AVPN__c','Onsite Install');
                    }else if(catalogRecordDataMap.get(catalogID).Description__c == 'Tele Install'){
                        catalogDataMap.put('Install_Option_MIS__c','Tele Install');
                        catalogDataMap.put('Install_Option_AVPN__c','Tele Install');
                    }
                    catalogDataMap.put('Installation_Catalog_Id__c',catalogID);
                    System.debug('@@@INSTALLATION - catalogDataMap:'+catalogDataMap);
                }
                else if((catalogRecordDataMap.get(catalogID).RecordType.Name).containsIgnoreCase('HiCapFlex Catalog') && (catalogRecordDataMap.get(catalogID).RecordType.Name).equalsIgnoreCase('HiCapFlex Catalog')!= null && (catalogRecordDataMap.get(catalogID).RecordType.Name).equalsIgnoreCase('HiCapFlex Catalog')){
                    catalogDataMap.put('UBB_Speed_AVPN__c',catalogRecordDataMap.get(catalogID).Speed_Value__c);
                    catalogDataMap.put('UBB_Speed_MIS__c',catalogRecordDataMap.get(catalogID).Speed_Value__c);
                    catalogDataMap.put('Hi_Cap_Flex__c','True');
                    catalogDataMap.put('Hi_cap_Flex_catalog_Id__c',catalogID);
                    System.debug('@@@HICAP - catalogDataMap:'+catalogDataMap);
                    
                }else if((catalogRecordDataMap.get(catalogID).RecordType.Name).containsIgnoreCase('DNS Catalog') && (catalogRecordDataMap.get(catalogID).RecordType.Name).equalsIgnoreCase('DNS Catalog')!= null && (catalogRecordDataMap.get(catalogID).RecordType.Name).equalsIgnoreCase('DNS Catalog')){
                    if(catalogRecordDataMap.get(catalogID).Description__c.containsIgnoreCase('Primary DNS')){
                        catalogDataMap.put('Additional_DNS__c','Primary');
                    }else if(catalogRecordDataMap.get(catalogID).Description__c.containsIgnoreCase('Secondary DNS')){
                        catalogDataMap.put('Additional_DNS__c','Secondary');
                    }
                    catalogDataMap.put('DNS_catalog_Id__c',catalogID);
                    System.debug('@@@DNS - catalogDataMap:'+catalogDataMap);
                    
                }else if((catalogRecordDataMap.get(catalogID).RecordType.Name).containsIgnoreCase('IPFlex Catalog') && (catalogRecordDataMap.get(catalogID).RecordType.Name).equalsIgnoreCase('IPFlex Catalog') != null && (catalogRecordDataMap.get(catalogID).RecordType.Name).equalsIgnoreCase('IPFlex Catalog')){
                    catalogDataMap.put('AT_T_IP_Flexible_Reach__c','True');
                    if(catalogRecordDataMap.get(catalogID).Description__c.containsIgnoreCase('Plan A')){
                        catalogDataMap.put('IP_Flexible_Reach_Plan__c','Plan A');
                    }else if(catalogRecordDataMap.get(catalogID).Description__c.containsIgnoreCase('Plan B')){
                        catalogDataMap.put('IP_Flexible_Reach_Plan__c','Plan B');
                    }else if(catalogRecordDataMap.get(catalogID).Description__c.containsIgnoreCase('Plan C')){
                        catalogDataMap.put('IP_Flexible_Reach_Plan__c','Plan C');
                    }
                    catalogDataMap.put('IPFlex_catalog_Id__c',catalogID);   
                    System.debug('@@@IPFLEX - catalogDataMap:'+catalogDataMap);
                }
            }
        }
        return catalogDataMap;
    }
    
    /*Method which returns Map of Catalog Ids from Configuration Data*/    
    public Map<String,String> getCatalogIdFromData(Map<String,string> dataMap){
        map<String,String> misPlMapping = new Map<String, String>{'1.544'=>'1.544','3'=>'3.088','4.5'=>'4.632','6'=>'6.176','7.5'=>'7.720','9'=>'9.264','10.5'=>'10.808','12'=>'12.352'};
        Map<String,String> CatalogMap = new Map<String,String>();
        try{
            for(APEX_Product_Catalog__c catalog: [SELECT Access_Architecture__c,Access_Needed__c,Access_Type__c,Active__c,BVoip_Ip_Id__c,BVoip_Line_Features__c,BVoip_Local__c,BVoip_Truck_Calling__c,Compatible_Access_ID__c,Compatible_DNS_ID__c,Compatible_Install_ID__c,Compatible_IPFlex_ID__c,Compatible_MBC__c,Compatible_Service_Code__c,Concurrent_Calls_Max__c,Concurrent_Calls_Min__c,Connectivity_Type__c,CreatedById,CreatedDate,Default_Access_Id__c,Default_Cos_ID__c,Default_Hicap_ID__c,Default_Install__c,Description__c,Dw_Speed__c,Flatrate_Indicator__c,Hicap_Indicator__c,Id,IsDeleted,Managed_Service__c,MBC_Description__c,Name,OwnerId,Port_Key_Value__c,Product_Abbrevation__c,RecordTypeId,RecordType.Name,Service_Code__c,Service_ID__c,Service_Name__c,Access_Key_Value__c,Service_Segment__c,Service_Type__c,Speed_Name__c,Speed_Type__c,Speed_Unit__c,Speed_Value__c,SystemModstamp,Transport_Type__c,Up_Speed__c,Version__c,Vlan__c FROM APEX_Product_Catalog__c where Active__c=true]){
                System.debug('RecordType Name:'+catalog.RecordType.Name);
                if(catalog.RecordType.Name.equalsIgnoreCase('Port Catalog')){                    
                    CatalogMap.put(catalog.Port_Key_Value__c,catalog.Name);
                    System.debug('catalog.Port_Key_Value__c  :' +catalog.Port_Key_Value__c);                    
                }else if(catalog.RecordType.Name.equalsIgnoreCase('Access Catalog')){
                    CatalogMap.put(catalog.Access_Key_Value__c,catalog.Name);
                    System.debug('accessCatalogMap : '+CatalogMap); 
                }else if(catalog.RecordType.Name.equalsIgnoreCase('COS Catalog')){
                    String keyvalue=catalog.Service_Name__c;
                    CatalogMap.put(keyvalue,catalog.Name);
                    System.debug('portCatalogMap : '+CatalogMap);
                }else if(catalog.RecordType.Name.equalsIgnoreCase('Installation Catalog')){
                    if(catalog.Description__c.equalsIgnoreCase('On-Site Install')){
                        catalog.Description__c='Onsite Install';
                    }
                    String keyvalue=catalog.Description__c;
                    CatalogMap.put(keyvalue,catalog.Name);
                    System.debug('portCatalogMap : '+CatalogMap);
                }else if(catalog.RecordType.Name.equalsIgnoreCase('HiCapFlex Catalog')){
                    String keyvalue=catalog.Speed_Value__c;
                    CatalogMap.put(keyvalue,catalog.Name);
                    System.debug('portCatalogMap : '+CatalogMap);
                }else if(catalog.RecordType.Name.equalsIgnoreCase('DNS Catalog')){
                    if(catalog.Description__c.equalsIgnoreCase('Primary DNS')){
                        catalog.Description__c='Primary';
                    }else if(catalog.Description__c.equalsIgnoreCase('Secondary DNS')){
                        catalog.Description__c='Secondary';
                    }
                    String keyvalue=catalog.Description__c ;
                    CatalogMap.put(keyvalue,catalog.Name);
                    System.debug('portCatalogMap : '+CatalogMap);
                }else if(catalog.RecordType.Name.equalsIgnoreCase('IPFlex Catalog')){
                    if(catalog.Description__c.equalsIgnoreCase('AT&T IPFLEX Reach Plan A')){
                        catalog.Description__c='Plan A';
                    }else if(catalog.Description__c.equalsIgnoreCase('AT&T IPFLEX Reach Plan B')){
                        catalog.Description__c='Plan B';
                    }else if(catalog.Description__c.equalsIgnoreCase('AT&T IPFLEX Reach Plan C')){
                        catalog.Description__c='Plan C';
                    }
                    String keyvalue=catalog.Description__c;
                    CatalogMap.put(keyvalue,catalog.Name);
                    System.debug('portCatalogMap : '+CatalogMap);
                }
            }
        }catch(Exception e){
            System.debug('exception caught '+e.getMessage());
        }
        
        Map<String,String> catalogIdMap = new Map<String,String>();
        
        if(dataMap.containsKey('ProductName__c') && (dataMap.get('ProductName__c')!= null) && dataMap.containsKey('Port_Type_MIS__c')  && (dataMap.get('Port_Type_MIS__c')!= null) && dataMap.containsKey('Port_Speed_MIS__c') && (dataMap.get('Port_Speed_MIS__c')!= null) && dataMap.containsKey('Access_Type__c') && (dataMap.get('Access_Type__c')!= null) && dataMap.containsKey('Access_Speed_MIS__c') && (dataMap.get('Access_Speed_MIS__c')!= null) && dataMap.containsKey('Install_Option_MIS__c') && (dataMap.get('Install_Option_MIS__c')!= null) && dataMap.containsKey('Managed_Router__c') && dataMap.containsKey('Interface_Type__c')){
            if(dataMap.get('ProductName__c').equalsIgnoreCase('AMIS')){
                if(dataMap.get('Interface_Type__c')!= null){
                    if(dataMap.get('Interface_Type__c').equalsIgnoreCase('Optical Single Mode - 1000 Base LX') || dataMap.get('Interface_Type__c').equalsIgnoreCase('Optical Multi Mode - 1000 Base SX')){
                        dataMap.put('Interface_Type__c' ,'Optical');
                    }else if(dataMap.get('Interface_Type__c').equalsIgnoreCase('Electrical - 100 Base TX') ){
                         dataMap.put('Interface_Type__c' ,'Electrical'); 
                    }
                }else{
                    dataMap.put('Interface_Type__c' ,'');
                }   
                
                if(dataMap.get('Port_Type_MIS__c').equalsIgnoreCase('Switched Ethernet')){
                    String port = dataMap.get('ProductName__c')+' '+dataMap.get('Port_Type_MIS__c')+' '+dataMap.get('Port_Speed_MIS__c')+' '+dataMap.get('Interface_Type__c')+' '+dataMap.get('Managed_Router__c').toLowerCase();                    
                    System.debug('port :'+port);
                    if(CatalogMap.containsKey(port)){
                        catalogIdMap.put('Port_Catalog_Id__c',CatalogMap.get(port));
                    }
                }else if(dataMap.get('Port_Type_MIS__c').equalsIgnoreCase('Private Line')){
                    String temp = dataMap.get('Port_Speed_MIS__c').replaceAll('[()]','');
                    dataMap.put('Port_Speed_MIS__c',temp);
                    System.debug('temp : '+temp);
                    List<String> portSpeedPL = dataMap.get('Port_Speed_MIS__c').split(' ');
                    dataMap.put('Port_Speed_MIS__c',portSpeedPL[1]+' '+portSpeedPL[2]);
                    system.debug('Port_Speed_MIS__c :'+portSpeedPL[1]);
                    System.debug('portSpeedPL : '+portSpeedPL);
                    String port = dataMap.get('ProductName__c')+' '+dataMap.get('Port_Type_MIS__c')+' '+dataMap.get('Port_Speed_MIS__c')+' '+dataMap.get('Interface_Type__c')+' '+dataMap.get('Managed_Router__c').toLowerCase();
                    System.debug('port :'+port);
                    if(CatalogMap.containsKey(port)){
                        catalogIdMap.put('Port_Catalog_Id__c',CatalogMap.get(port));
                    }
                }
                if(dataMap.get('Access_Type__c').equalsIgnoreCase('Switched Ethernet')){
                    dataMap.put('Access_Type__c','ETHERNET');
                    String access = dataMap.get('Access_Type__c')+' '+dataMap.get('Access_Speed_MIS__c');
                    System.debug('access :'+access);
                    if(CatalogMap.containsKey(access)){
                        catalogIdMap.put('Access_Catalog_Id__c',CatalogMap.get(access));
                    }
                } 
                if(dataMap.get('Access_Type__c').equalsIgnoreCase('Private Line')){
                    String temp = dataMap.get('Access_Speed_MIS__c').replaceAll('[()]','');
                    List<String> accessSpeedPL = temp.split(' ');
                    System.debug('access Speed PL : '+accessSpeedPL);
                    dataMap.put('Access_Speed_MIS__c',misPlMapping.get(accessSpeedPL[1])+' '+accessSpeedPL[2]);
                    System.debug('Access_Speed_MIS__c :'+dataMap.get('Access_Speed_MIS__c'));
                    String access = dataMap.get('Access_Type__c')+' '+dataMap.get('Access_Speed_MIS__c');
                    System.debug('access :'+access);
                    if(CatalogMap.containsKey(access)){
                        catalogIdMap.put('Access_Catalog_Id__c',CatalogMap.get(access));
                    }
                }
                if(dataMap.containsKey('CoS__c') && (dataMap.get('CoS__c')!= null)){
                    if( dataMap.get('CoS__c').equalsIgnoreCase('true')){
                        String cos = 'Class of Service';
                        System.debug('cos :'+cos);
                        if(CatalogMap.containsKey(cos)){
                            catalogIdMap.put('COS_catalog_Id__c',CatalogMap.get(cos));
                        }
                    }
                }
                String install = dataMap.get('Install_Option_MIS__c');
                System.debug('install :'+install);
                if(CatalogMap.containsKey(install)){
                    catalogIdMap.put('Installation_Catalog_Id__c',CatalogMap.get(install));
                }
                
                if(dataMap.containsKey('Hi_Cap_Flex__c') && (dataMap.get('Hi_Cap_Flex__c')!= null)&& dataMap.containsKey('UBB_Speed_MIS__c') && (dataMap.get('UBB_Speed_MIS__c')!= null)){
                    if( dataMap.get('Hi_Cap_Flex__c').equalsIgnoreCase('true')){
                        String hicap = dataMap.get('UBB_Speed_MIS__c');
                        System.debug('hicap :'+hicap);
                        if(CatalogMap.containsKey(hicap)){
                            catalogIdMap.put('Hi_cap_Flex_catalog_Id__c',CatalogMap.get(hicap));
                        }
                    }
                }
                if(dataMap.containsKey('Additional_DNS__c') && (dataMap.get('Additional_DNS__c')!= null)){
                    String dns = dataMap.get('Additional_DNS__c');
                    System.debug('dns :'+dns);
                    if(CatalogMap.containsKey(dns)){
                        catalogIdMap.put('DNS_catalog_Id__c',CatalogMap.get(dns));
                    }
                }
                if(dataMap.containsKey('AT_T_IP_Flexible_Reach__c') && (dataMap.get('AT_T_IP_Flexible_Reach__c')!= null)&& dataMap.containsKey('IP_Flexible_Reach_Plan__c') && (dataMap.get('IP_Flexible_Reach_Plan__c')!= null)){
                    if( dataMap.get('AT_T_IP_Flexible_Reach__c').equalsIgnoreCase('true')){
                        String ipflex = dataMap.get('IP_Flexible_Reach_Plan__c');
                        System.debug('ipflex :'+ipflex);
                        if(CatalogMap.containsKey(ipflex)){
                            catalogIdMap.put('IPFlex_catalog_Id__c',CatalogMap.get(ipflex));
                        }
                    }
                }
            }
        }
        else if(dataMap.containsKey('ProductName__c') && (dataMap.get('ProductName__c')!= null) && dataMap.containsKey('Port_Type_AVPN__c')&& (dataMap.get('Port_Type_AVPN__c')!= null) && dataMap.containsKey('Port_Speed_AVPN__c') && (dataMap.get('Port_Speed_AVPN__c')!= null) && dataMap.containsKey('Access_Type_AVPN__c') && (dataMap.get('Access_Type_AVPN__c')!= null) && dataMap.containsKey('Access_Speed_AVPN__c') && (dataMap.get('Access_Speed_AVPN__c')!= null) && dataMap.containsKey('Install_Option_AVPN__c') && (dataMap.get('Install_Option_AVPN__c')!= null) && dataMap.containsKey('Interface_Type_AVPN__c') && dataMap.containsKey('Managed_Router__c')){
            if(dataMap.get('ProductName__c').equalsIgnoreCase('AVPN')){
                if(dataMap.get('Interface_Type_AVPN__c')!= null){
                    if(dataMap.get('Interface_Type_AVPN__c').equalsIgnoreCase('Optical Single Mode - 1000 Base LX') || dataMap.get('Interface_Type_AVPN__c').equalsIgnoreCase('Optical Multi Mode - 1000 Base SX')){
                        dataMap.put('Interface_Type_AVPN__c' ,'Optical');
                    }else if(dataMap.get('Interface_Type_AVPN__c').equalsIgnoreCase('Electrical - 100 Base TX') ){
                         dataMap.put('Interface_Type_AVPN__c' ,'Electrical'); 
                    }
                }else{
                    dataMap.put('Interface_Type_AVPN__c' ,'');
                }   
                if(dataMap.get('Port_Type_AVPN__c').equalsIgnoreCase('Switched Ethernet')){
                    String port = dataMap.get('ProductName__c')+' '+dataMap.get('Port_Type_AVPN__c')+' '+dataMap.get('Port_Speed_AVPN__c')+' '+dataMap.get('Interface_Type_AVPN__c')+' '+dataMap.get('Managed_Router__c').toLowerCase();
                    System.debug('port :'+port);
                    if(CatalogMap.containsKey(port)){
                        catalogIdMap.put('Port_Catalog_Id__c',CatalogMap.get(port));
                    }
                }
                else if(dataMap.get('Port_Type_AVPN__c').equalsIgnoreCase('Private Line')){
                    String temp = dataMap.get('Port_Speed_AVPN__c').replaceAll('[()]','');
                    dataMap.put('Port_Speed_AVPN__c',temp);
                    System.debug('temp : '+temp);
                    List<String> portSpeedPL = dataMap.get('Port_Speed_AVPN__c').split(' ');
                    dataMap.put('Port_Speed_AVPN__c',portSpeedPL[1]+' '+portSpeedPL[2]);
                    System.debug('portSpeedPL : '+portSpeedPL);
                    String port = dataMap.get('ProductName__c')+' '+dataMap.get('Port_Type_AVPN__c')+' '+dataMap.get('Port_Speed_AVPN__c')+' '+dataMap.get('Interface_Type_AVPN__c')+' '+dataMap.get('Managed_Router__c').toLowerCase();
                    System.debug('port :'+port);
                    if(CatalogMap.containsKey(port)){
                        catalogIdMap.put('Port_Catalog_Id__c',CatalogMap.get(port));
                    }
                } 
                System.debug('dataMap'+dataMap);
                if(dataMap.get('Access_Type_AVPN__c').equalsIgnoreCase('Switched Ethernet')){
                    dataMap.put('Access_Type_AVPN__c','ETHERNET');
                    String access = dataMap.get('Access_Type_AVPN__c')+' '+dataMap.get('Access_Speed_AVPN__c');
                    System.debug('access :'+access);
                    if(CatalogMap.containsKey(access)){
                        catalogIdMap.put('Access_Catalog_Id__c',CatalogMap.get(access));
                    }
                }
                
                if(dataMap.get('Access_Type_AVPN__c').equalsIgnoreCase('Private Line')){
                    String temp = dataMap.get('Access_Speed_AVPN__c').replaceAll('[()]','');
                    List<String> accessSpeedPL = temp.split(' ');
                    System.debug('access Speed PL : '+accessSpeedPL);
                    dataMap.put('Access_Speed_AVPN__c',accessSpeedPL[1]+' '+accessSpeedPL[2]);
                    System.debug('Access_Speeeeed_AVPN__c :'+dataMap.get('Access_Speed_AVPN__c'));
                    String access = dataMap.get('Access_Type_AVPN__c')+' '+dataMap.get('Access_Speed_AVPN__c');
                    System.debug('access :'+access);
                    if(CatalogMap.containsKey(access)){
                        catalogIdMap.put('Access_Catalog_Id__c',CatalogMap.get(access));
                    }
                }
                if(dataMap.containsKey('CoS__c') && (dataMap.get('CoS__c')!= null)){
                    if(dataMap.get('CoS__c').equalsIgnoreCase('true')){
                        String cos = 'Class of Service';
                        System.debug('cos :'+cos);
                        if(CatalogMap.containsKey(cos)){
                            catalogIdMap.put('COS_catalog_Id__c',CatalogMap.get(cos));
                        }
                    }
                }
                String install = dataMap.get('Install_Option_AVPN__c');
                System.debug('install :'+install);
                if(CatalogMap.containsKey(install)){
                    catalogIdMap.put('Installation_Catalog_Id__c',CatalogMap.get(install));
                }
                if(dataMap.containsKey('Hi_Cap_Flex__c') && (dataMap.get('Hi_Cap_Flex__c')!= null) && dataMap.containsKey('UBB_Speed_AVPN__c') && (dataMap.get('UBB_Speed_AVPN__c')!= null)){
                    if(dataMap.get('Hi_Cap_Flex__c').equalsIgnoreCase('true')){
                        String hicap = dataMap.get('UBB_Speed_AVPN__c');
                        System.debug('hicap :'+hicap);
                        if(CatalogMap.containsKey(hicap)){
                            catalogIdMap.put('Hi_cap_Flex_catalog_Id__c',CatalogMap.get(hicap));
                        }
                    }
                }
                if(dataMap.containsKey('AT_T_IP_Flexible_Reach__c') && (dataMap.get('AT_T_IP_Flexible_Reach__c')!= null) && dataMap.containsKey('IP_Flexible_Reach_Plan__c') && (dataMap.get('IP_Flexible_Reach_Plan__c')!= null)){
                    if( dataMap.get('AT_T_IP_Flexible_Reach__c').equalsIgnoreCase('true')){
                        String ipflex = dataMap.get('IP_Flexible_Reach_Plan__c');
                        System.debug('ipflex :'+ipflex);
                        if(CatalogMap.containsKey(ipflex)){
                            catalogIdMap.put('IPFlex_catalog_Id__c',CatalogMap.get(ipflex));
                        }
                    }
                }
            }
        }
        System.debug('CatalogIdMap : '+catalogIdMap);
        return catalogIdMap;  
    }
}