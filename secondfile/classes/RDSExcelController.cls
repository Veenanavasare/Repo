/************************************************************************************** 
Apex Class Name     : RDSExcelController
Version             : 1.0 
Created Date        : 17 Jan 2017
Function            : RDS excel
*************************************************************************************/
public class RDSExcelController{
    String dhId;
    public static Id opptID;
    public String quoteId {get;set;}
    public String opportunityId{get;set;}
    public String product {get;set;}
    public String flowType {get;set;}
    public static string flowFirstCell{get;set;}
    public String excelName;
    public Apttus_Proposal__Proposal__c quoteObj {get;set;}
    public Opportunity oppObj {get;set;}
    public List<RDS_Premise_Details__c> premiseDetailsList = new List<RDS_Premise_Details__c>(); 
    public List<RDS_IPFLEX_Details__c> premiseDetailsIpfDetailsList = new List<RDS_IPFLEX_Details__c>(); 
    public List<RDS_Contact__c> rdsContactList = new List<RDS_Contact__c>();
    public List<Circuit_and_VLAN_Details__c> cktVlanDetailsList = new List<Circuit_and_VLAN_Details__c>();
    public List<VLAN_Information__c> rdsVlanInfo = new List<VLAN_Information__c>();
    public List<RDS_V4_Family_Data__c> v4FamilyList = new List<RDS_V4_Family_Data__c>();
    public List<RDS_V4_LAN_IP_Address__c> v4LanIpAddressList = new List<RDS_V4_LAN_IP_Address__c>();
    public List<RDS_V6_LAN_IP_Address__c> v6LANIPAddressList = new  List<RDS_V6_LAN_IP_Address__c>();
    public List<V6_Family_Data__c> v6familyList = new List<V6_Family_Data__c>();
    public List<RDS_V4_Family_Data__c> v4familyListVLAN = new List<RDS_V4_Family_Data__c>();
    public List<V6_Family_Data__c> v6familyListVLAN = new List<V6_Family_Data__c>();
    public String orderNumber {get; set;}
    public String termLength {get; set;} 
    public String endCustomerName {get; set;} 
    public String businessName {get; set;} 
    public Set<String> premiseIds = new Set<String>();
    public Set<Id> cvlanIds = new Set<Id>(); 
    public WrapperUIRenderComponent wrc{get;set;} 
    public List<RDS_V4_LAN_IP_Address__c> v4IPAddressList {get;set;}
    public List<RDS_V6_LAN_IP_Address__c> v6IPAddressList {get;set;}
    public String domainURLfromObj;
    public String domainId;
    //  Map<Integer,List<String>>  sectionKeysMap;
    public Map<String,String> blankMap = new Map<String,String>();
    public String premisesectionName;
    WrapperUIRenderComponentBuilder      wrcb;
    public Integer sectionColId;
    public Set<String> v4Ids = new Set<String>();  
    public Set<String> v6Ids = new Set<String>();  
    public Set<String> vlaninfoIds = new Set<String>();  
    public List<Attachment> attList;
    public List<SPProduct__c> addDNSfromSPP = new List<SPProduct__c>();
    public String ipflexDeal;
    Public Boolean misplus;
    public Map<String,String> ipFlexPlanMap  = new Map<String,String>();
    public Map<String,String> premiseMISPlusMap = new Map<String,String>();
    

    /*
    * Method Name: RDSExcelController constructor
    */
    public RDSExcelController(Id opportId,String prodct,String fType){
        product=prodct;
        flowType=  fType;
        flowFirstCell = flowType;
        opportunityId= opportId;
        try{   
            if(opportunityId==null || opportunityId==RDSExcelExportIndicesKeys.sk_DOUBLE_QOUTES){                  
                quoteId = apexpages.currentpage().getparameters().get(RDSExcelExportIndicesKeys.sk_quoteId);
            }
            String   actionType = RDSExcelExportIndicesKeys.sk_ExportRds;
            wrc= new WrapperUIRenderComponent(RDSExcelExportIndicesKeys.sk_OpptyInformation+actionType);
            wrcb= new WrapperUIRenderComponentBuilder (wrc,RDSExcelExportIndicesKeys.sk_RegenerateRDSExcel,RDSExcelExportIndicesKeys.sk_BuyFlow,RDSExcelExportIndicesKeys.sk_Flow,actionType);           
            renderExcelData(wrcb);
            getQuoteRef(wrcb);
        }catch (exception e) {
            System.debug('*******exception in pricing schedule template*****' + e.getLineNumber()+RDSExcelExportIndicesKeys.sk_DOUBLE_QOUTES+e+'trace is :'+e.getStackTraceString());
            throw e;
        } 
    }
    /*
    * Method Name: RDSExcelController
    */
    public RDSExcelController(){
        try{                       
            if(quoteId==null || quoteId==RDSExcelExportIndicesKeys.sk_DOUBLE_QOUTES){                  
                quoteId = apexpages.currentpage().getparameters().get(RDSExcelExportIndicesKeys.sk_quoteId);  
            }
            String   actionType = RDSExcelExportIndicesKeys.sk_ExportRds;
            wrc= new WrapperUIRenderComponent(RDSExcelExportIndicesKeys.sk_OpptyInformation+actionType);
            wrcb= new WrapperUIRenderComponentBuilder (wrc,RDSExcelExportIndicesKeys.sk_RegenerateRDSExcel,RDSExcelExportIndicesKeys.sk_BuyFlow,RDSExcelExportIndicesKeys.sk_Flow,actionType);           
            RDSExcelExportIndicesMap indicesMapClass = new RDSExcelExportIndicesMap();
            renderExcelData(wrcb);
            getQuoteRef(wrcb);
        }catch (exception e) {
            System.debug('*********exception Caught ******' + e.getLineNumber()+RDSExcelExportIndicesKeys.sk_DOUBLE_QOUTES+e+'trace is :'+e.getStackTraceString());
            throw e;
        } 
    }
    
    /*
    * Method Name: attachCSVtoOppty
    * Method from testJuly since UAT and TestJuly were not in sycn . UAT has excel sheer 
    */
    public void attachCSVtoOppty(){
          GridDataToCSVConverter gdcc= new GridDataToCSVConverter ();
          gdcc.generateCSVForGridData(wrc,opportunityId,Excelname);
       
    }
    /*
    * Method Name: renderExcelData
    */
    public Void renderExcelData(WrapperUIRenderComponentBuilder wrcb ){
        try{     
            Integer  totalKeysLenght;  
            if(product == BuyflowConstant.AVPN){
                totalKeysLenght=RDSExcelExportMap.sectionKeys.size();
            }
            else if(product == BuyflowConstant.AMIS){
                totalKeysLenght=MISRDSExcelExportMap.sectionKeys.size();
            } 
            integer k=0;
            List<String> keysList;
            for(integer i=1;i<=totalKeysLenght;i++){
                if(product == BuyflowConstant.AVPN){
                    keysList =RDSExcelExportMap.sectionKeys.get(i);
                }
                if(product == BuyflowConstant.AMIS){
                    keysList=MISRDSExcelExportMap.sectionKeys.get(i);
                }
                String key=RDSExcelExportIndicesKeys.sk_DOUBLE_QOUTES;
                for(integer j=0;j<keysList.size();j++){
                    if(i==0 && j==0){
                        key=keysList[j]+RDSExcelExportIndicesKeys.sk_HYPHEN+flowType;
                    }else{
                        key=keysList[j];
                    }
                    wrcb.loadSectionElementAsCoreMap(key,key,key+RDSExcelExportIndicesKeys.sk_underscore+j,RDSExcelExportIndicesKeys.sk_DOUBLE_QOUTES+i,i,j+1,false);         
                    k++;
                }
            }
        }catch (exception e) {
            System.debug('*******exception Caught *****'+e.getLineNumber()+SpecialCharacterConstant.CONCAT+e+'trace is:'+e.getStackTraceString());
            throw e;
        }
    }
    
    Map<String,Map<String,RDS_Contact__c>> rdsContactsMap;
    
    /* initializeContatsMap */
    public void  initializeContatsMap(Set<String> premiseIds){
        rdsContactsMap= new     Map<String,Map<String,RDS_Contact__c>>();
        for(String premisId : premiseIds){
            rdsContactsMap.put(premisId, new Map<String,RDS_Contact__c>());
        }
    }
    
    /*generateContactsMap*/
    public void generateContactsMap(Set<String> premiseIds,List<RDS_Contact__c>  rdsContactList){
        for(RDS_Contact__c rdsContact : rdsContactList){
            Map<String,RDS_Contact__c> premiseRDSConList=   rdsContactsMap.get(rdsContact.RDS_Premise_Details_Number__r.id+RDSExcelExportIndicesKeys.sk_DOUBLE_QOUTES);
            premiseRDSConList.put(rdsContact.Contact_Type__c,rdsContact );
        }
    }
    Decimal opptyVersion ;
    
    /* get dhId*/
    public String  getDealHashID(){
        return dhId;
    }
    
    /* get OpptyVersion*/
    public Decimal getOpptyVersion(){
        return OpptyVersion;
    }
    
    /*
    * Name: getQuoteRef
    */
    public void getQuoteRef(WrapperUIRenderComponentBuilder wrcb){
            Integer sectionListSize= wrc.getElementListSize('WrapperUISection');            
        if(opportunityId != NULL){
            oppObj = new Opportunity();
            oppObj = [Select Id,Name,IPFlex_Deal__c,MISPlus__c,MACD_Type__c,RDS_Deal_Hash__r.Term__c,RDS_Version__c,
                      RDS_Deal_Hash__r.Customer_Business_Name__c,RDS_Deal_Hash__r.End_Customer_Name__c,RDS_Deal_Hash__r.id
                      from Opportunity where Id=: opportunityId]; 
            OpptID =  opportunityId;  
            ipflexDeal = oppObj.IPFlex_Deal__c;
            misplus=oppObj.MISPlus__c;
            if(oppObj != null){
                createfileName(oppObj.name,oppObj.MACD_Type__c);
                orderNumber=oppObj.name;
                termLength = oppObj.RDS_Deal_Hash__r.Term__c;
                endCustomerName = oppObj.RDS_Deal_Hash__r.End_Customer_Name__c;
                businessName = oppObj.RDS_Deal_Hash__r.Customer_Business_Name__c;
                String oppId = oppObj.id;
                OpptyVersion = oppObj.RDS_Version__c;
                //RDS-DealHash Fields
                dhId = oppObj.RDS_Deal_Hash__r.id;
            }}
        wrcb.loadSectionElementAsCoreMap(RDSExcelExportIndicesKeys.sk_Order_Number,orderNumber,BuyflowConstant.ORDER_NUMBER_COLON1_2_1_CONST,BuyflowConstant.SIVARConst_2,2,2,false); 
        wrcb.loadSectionElementAsCoreMap(RDSExcelExportIndicesKeys.sk_Select_Term,termLength ,BuyflowConstant.SELECT_TERM1_2_2_CONST,BuyflowConstant.SIVARConst_3,3,2,false); 
        wrcb.loadSectionElementAsCoreMap(RDSExcelExportIndicesKeys.sk_Business_Name,businessName,BuyflowConstant.BUSINESS_NAME1_1_3_CONST,BuyflowConstant.SIVARConst_4,4,2,false); 
        wrcb.loadSectionElementAsCoreMap(RDSExcelExportIndicesKeys.sk_End_Customer_Name,endCustomerName ,BuyflowConstant.END_CUSTOMER_NAME1_1_4_CONST,BuyflowConstant.SIVARConst_5,5,2,false); 
        if(dhId != null && dhId != RDSExcelExportIndicesKeys.sk_DOUBLE_QOUTES){     
            premiseDetailsList = [select Premise_Friendly_Name__c,Remarks__c,Premise_Number__c,DealHash__c,RDS_Version__c,Customer_Purchase_Decision_Date__c,Request_Due_Date__c,Planned_Turn_up_Date__c,Working_Telephone_Number__c,Notes__c,MLDB_Street_Number__c,
                                  MLDB_Street_Direction__c,MLDB_Street_Name__c,MLDB_Street_Type__c,MLDB_Street_Trailing_Direction__c,MLDB_Building__c,MLDB_Floor__c,MLDB_Room__c,MLDB_City__c,MLDB_State__c,MLDB_Zipcode__c,
                                  MLDB_Zipcode_Extension__c,MLDB_Country__c,Transport_Type__c,VLAN_Count__c FROM RDS_Premise_Details__c WHERE  DealHash__c =:dhId AND RDS_Version__c =: OpptyVersion];                    
            sectionColId=3;
            Set<String> premiseNumbers = new Set<String>();
            if(premiseDetailsList != null && premiseDetailsList.size()>0){
                for(RDS_Premise_Details__c prems : premiseDetailsList){
                    premiseIds.add(prems.Id);
                    premiseNumbers.add(prems.Premise_Number__c);
                } 
            premiseDetailsIpfDetailsList = [SELECT RDS_Premise_Details__c,RDS_Premise_Details__r.Premise_number__c,PBX_Model_Session_Manager__c,Router_Shipping_First_Name__c,Router_Shipping_Last_Name__c,Router_Shipping_Phone_Number__c,Router_Shipping_Address_1__c,Router_Shipping_Floor_Number__c,Router_Shipping_Room_Number__c,
                                        Router_Shipping_City__c,Router_Shipping_State__c,Router_Shipping_Zip_Code__c,IPFlex_Reach_Traffic_Type__c,Number_of_static_IP_addresses__c,IP_Flexible_Reach_Calling_Plan__c,No_of_Concurrent_Calls__c,
                                        IPFlex_Reach_Private_Dial_Plan__c,Rate_Center__c,Req_to_sup_IPFlex_on_AVPN_Outside_Move__c,POTS_for_testing_router__c,POTS_Phone_Number__c,PBX_or_Voice_CPE_POC_First_Name__c,PBX_or_Voice_CPE_POC_Last_Name__c,
                                        PBX_or_Voice_CPE_POC_Email__c,PBX_or_Voice_CPE_POC_Phone_Number__c,Req_to_sup_IPFlex_on_MIS_Outside_Move__c,Date_of_IPFlex_on_AVPN_Outside_Move__c,Date_of_IPFlex_on_MIS_Outside_Move__c,VQM_Type__c,PBX_Type__c,CODEC__c,
                                        PBX_Interface_Type__c,CE_Router_Vendor_or_Mfg__c,CE_Router_Model__c,CE_Router_Software_Version__c,SBC_cascaded_integrated_with_CE_Router__c,PBX_Vendor_Mfg__c,PBX_Model__c,PBX_Software_Version__c,SBC_Name__c,SBC_Software_Version__c,
                                        SBC_Vendor__c,Number_of_SBCs_for_the_site__c,CPE_Certification_Status__c,IVR_Vendor_Model_Name_Release_Version__c,IVR_behind_the_PBX_or_Standalone__c,Inbound_Alternate_Call_Routing__c,Using_BGPR__c,Backdoor_links__c,
                                        Call_preservation_required__c,Enhanced_Features_Services__c,Portal_Administrator_Email_Address__c,Portal_Administrator_First_Name__c,Portal_Administrator_Last_Name__c,Portal_Administrator_Phone_Number__c,
                                        Test_Call_Phone_Number1__c,Test_Call_Phone_Number2__c,Call_Forwarding_required__c,Trunk_Call_Routing_Management_Required__c,Portable_Numbers_on_Existing_IPFlex_Plan__c,Port_Type__c,Billing_Telephone_Number__c,
                                        New_Billing_Telephone_Number__c,Will_the_port_include_fax_number__c,CRS_Request_document_status__c,Number_of_Local_Phone_Numbers__c,Local_Phone_Number_Primary_NPA_NXX__c,Local_Phone_Number_Secondary_NPA_NXX__c,Number_of_Virtual_Phone_Numbers__c,
                                        Virtual_Phone_Number_Primary_NPA_NXX__c,Virtual_Phone_Number_Secondary_NPA_NXX__c,Collect_Calling_and_3rd_Party_Billing__c,Please_note_any_exceptions__c,Calling_Name_Display__c,Customer_Specified_CNAM__c,
                                        Directory_Listing_for_Phone_Number__c,Listed_Name__c,Listed_Number__c,Listing_Category__c,Listing_Option__c,Dir_Listing_Dir_Assistance_for_Address__c FROM RDS_IPFLEX_Details__c WHERE RDS_Premise_Details__c IN:premiseIds];
             addDNSfromSPP = [SELECT Id,Site_ID__c,Additional_DNS__c FROM SPProduct__c WHERE Site_ID__c IN: premiseNumbers];
            
            if(premiseDetailsIpfDetailsList != null && premiseDetailsIpfDetailsList.size()>0){
               for(RDS_IPFlex_Details__c premIPflex : premiseDetailsIpfDetailsList){ 
                   premiseMISPlusMap.put(premIPflex.RDS_Premise_Details__r.Premise_number__c,premIPflex.Router_Shipping_First_Name__c);
                   if(premIPflex.IP_Flexible_Reach_Calling_Plan__c !=null || misplus){
                        IPFlexPlanMap.put(premIPflex.RDS_Premise_Details__r.Premise_number__c,premIPflex.IP_Flexible_Reach_Calling_Plan__c);
                    }
                } 
             } 
            
            
          
                rdsContactList = [Select Contact_Type__c,RDS_Premise_Details_Number__r.id,RDS_Premise_Details_Number__c,Contact_First_Name__c,Contact_Last_Name__c,Contact_Phone__c,Contact_Mobile_Number__c,Contact_Email__c,Contact_Address_Line_1__c,Contact_Address_Line_2__c,Contact_City__c, Contact_State__c, Contact_Zipcode__c From RDS_Contact__c Where RDS_Premise_Details_Number__c IN: premiseIds];
                initializeContatsMap( premiseIds);
                generateContactsMap(premiseIds,  rdsContactList);
            }
        }
    }
    
    /*
    * Name: populatePremise
    */
    public void populatePremise(RDS_Premise_Details__c premise){
        premisesectionName = premise.id +RDSExcelExportIndicesKeys.sk_Section+sectionColId;
        Integer contactSize = premise.RDS_Contact__r.size();
        //to do check the sequence for MIS
        if(product == BuyflowConstant.AMIS){
            if(premise.IPFLEX__c || (premiseMISPlusMap.containsKey(premise.Premise_Number__c) && String.isNotBlank(premiseMISPlusMap.get(premise.Premise_Number__c)))){
                loadDataOnWRC(RDSExcelExportIndicesKeys.PREMISE_Router_Service_Type,'Plus',sectionColId,premisesectionName);
            }else{
                loadDataOnWRC(RDSExcelExportIndicesKeys.PREMISE_Router_Service_Type,'Basic',sectionColId,premisesectionName);
            }
            loadDataOnWRC(RDSExcelExportIndicesKeys.PREMISE_Has_existing_POTS_for_Testing_router,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);
            loadDataOnWRC(RDSExcelExportIndicesKeys.PREMISE_Out_of_Band_Number,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);
        }
        loadDataOnWRC(RDSExcelExportIndicesKeys.Header,RDSExcelExportIndicesKeys.sk_Site+(sectionColId-2)+RDSExcelExportIndicesKeys.sk_spaceHYPHEN+premise.MLDB_City__c,sectionColId,premisesectionName);
        loadDataOnWRC(RDSExcelExportIndicesKeys.PREMISE_SITE_NAME,premise.Premise_Friendly_Name__c,sectionColId,premisesectionName);
        if(product == BuyflowConstant.AVPN){
            loadDataOnWRC(RDSExcelExportIndicesKeys.PREMISE_VPN_Connection_Policy,RDSExcelExportIndicesKeys.sk_AnyToAny,sectionColId,premisesectionName);                         
        }
        loadDataOnWRC(RDSExcelExportIndicesKeys.PREMISE_Purchase_Decision_Date,premise.Customer_Purchase_Decision_Date__c.format(),sectionColId,premisesectionName);                         
        loadDataOnWRC(RDSExcelExportIndicesKeys.PREMISE_Requested_Service_Activation_Date_CRDD,premise.Request_Due_Date__c.format(),sectionColId,premisesectionName);                         
        loadDataOnWRC(RDSExcelExportIndicesKeys.PREMISE_Decline_early_service_and_provision_on_due_date,premise.Planned_Turn_up_Date__c,sectionColId,premisesectionName);                         
        loadDataOnWRC(RDSExcelExportIndicesKeys.PREMISE_Site_Phone_Number,premise.Working_Telephone_Number__c,sectionColId,premisesectionName);                         
        
        
        Map<String,RDS_Contact__c>  premiseconMaps=rdsContactsMap.get(premise.id);
        
        String[] keyset=new String[]{RDSExcelExportIndicesKeys.sk_PREMISE,RDSExcelExportIndicesKeys.sk_ALTERNATE_PREMISE,RDSExcelExportIndicesKeys.sk_BILLING,RDSExcelExportIndicesKeys.sk_SOLUTION_PROVIDER,RDSExcelExportIndicesKeys.sk_CUSTOMER,RDSExcelExportIndicesKeys.sk_TECHNICAL};
            for(integer m=0;m<keyset.size();m++){
                if(premiseconMaps.get(keySet[m]) != null){
                RDS_Contact__c  rdsCon=premiseconMaps.get(keySet[m]);
                loadDataOnWRC(rdsCon.Contact_Type__c+RDSExcelExportIndicesKeys.CONTACT_TYPE,rdsCon.Contact_Type__c,sectionColId,premisesectionName); 
                loadDataOnWRC(rdsCon.Contact_Type__c+RDSExcelExportIndicesKeys.First_Name,rdsCon.Contact_First_Name__c,sectionColId,premisesectionName); 
                loadDataOnWRC(rdsCon.Contact_Type__c+RDSExcelExportIndicesKeys.Last_Name,rdsCon.Contact_Last_Name__c,sectionColId,premisesectionName); 
                loadDataOnWRC(rdsCon.Contact_Type__c+RDSExcelExportIndicesKeys.Contact_Phone_Number,rdsCon.Contact_Phone__c,sectionColId,premisesectionName); 
                if(rdsCon.Contact_Type__c == 'BILLING' && product == BuyflowConstant.AMIS){
                    string billingAddress=SpecialCharacterConstant.CONCAT;
                    if(rdsCon.Contact_Address_Line_1__c != null && rdsCon.Contact_Address_Line_2__c == null){
                        billingAddress =rdsCon.Contact_Address_Line_1__c;
                    }
                    else if(rdsCon.Contact_Address_Line_1__c == null && rdsCon.Contact_Address_Line_2__c != null){
                        billingAddress =rdsCon.Contact_Address_Line_2__c;
                    }
                    else if(rdsCon.Contact_Address_Line_1__c != null && rdsCon.Contact_Address_Line_2__c != null){
                        billingAddress =rdsCon.Contact_Address_Line_1__c+' '+rdsCon.Contact_Address_Line_2__c;
                    }
                    loadDataOnWRC(rdsCon.Contact_Type__c+'_Billing_Address',billingAddress,sectionColId,premisesectionName); 
                    loadDataOnWRC(rdsCon.Contact_Type__c+'_Billing_City',rdsCon.Contact_City__c,sectionColId,premisesectionName);
                    loadDataOnWRC(rdsCon.Contact_Type__c+'_Billing_State',rdsCon.Contact_State__c,sectionColId,premisesectionName);
                    loadDataOnWRC(rdsCon.Contact_Type__c+'_Billing_Zip',rdsCon.Contact_Zipcode__c,sectionColId,premisesectionName);
                }
                if(rdsCon.Contact_Type__c == RDSExcelExportIndicesKeys.sk_PREMISE || rdsCon.Contact_Type__c == RDSExcelExportIndicesKeys.sk_ALTERNATE_PREMISE){
                    loadDataOnWRC(rdsCon.Contact_Type__c+RDSExcelExportIndicesKeys.Mobile_Phone_Number,rdsCon.Contact_Mobile_Number__c,sectionColId,premisesectionName); 
                }
                loadDataOnWRC(rdsCon.Contact_Type__c+RDSExcelExportIndicesKeys.Email_address,rdsCon.Contact_Email__c,sectionColId,premisesectionName);                    }                                                 
            }
        loadDataOnWRC(RDSExcelExportIndicesKeys.Street_Number,premise.MLDB_Street_Number__c,sectionColId,premisesectionName);  
        loadDataOnWRC(RDSExcelExportIndicesKeys.Street_Direction,premise.MLDB_Street_Direction__c,sectionColId,premisesectionName);
        loadDataOnWRC(RDSExcelExportIndicesKeys.Street_Name,premise.MLDB_Street_Name__c,sectionColId,premisesectionName);  
        loadDataOnWRC(RDSExcelExportIndicesKeys.Street_Type,premise.MLDB_Street_Type__c,sectionColId,premisesectionName);  
        loadDataOnWRC(RDSExcelExportIndicesKeys.Street_Trailing_Direction,premise.MLDB_Street_Trailing_Direction__c,sectionColId,premisesectionName);
        loadDataOnWRC(RDSExcelExportIndicesKeys.Building,premise.MLDB_Building__c,sectionColId,premisesectionName);  
        loadDataOnWRC(RDSExcelExportIndicesKeys.Floor,premise.MLDB_Floor__c,sectionColId,premisesectionName);  
        loadDataOnWRC(RDSExcelExportIndicesKeys.Room,premise.MLDB_Room__c,sectionColId,premisesectionName);  
        loadDataOnWRC(RDSExcelExportIndicesKeys.City,premise.MLDB_City__c,sectionColId,premisesectionName);  
        loadDataOnWRC(RDSExcelExportIndicesKeys.State,premise.MLDB_State__c,sectionColId,premisesectionName);  
        loadDataOnWRC(RDSExcelExportIndicesKeys.Zip,premise.MLDB_Zipcode__c,sectionColId,premisesectionName);  
        loadDataOnWRC(RDSExcelExportIndicesKeys.Zipcode_Extension,premise.MLDB_Zipcode_Extension__c,sectionColId,premisesectionName);  
        loadDataOnWRC(RDSExcelExportIndicesKeys.Country,premise.MLDB_Country__c,sectionColId,premisesectionName); 
        fetchRDSData(premise.id,premise.Remarks__c,premise.Notes__c);
        fetchIPFlexDetails(premise.id,premise.Premise_Number__c);
    }
    
    /*
    * Name: createfileName
    */
    public void createfileName(string quotename,string Mode)
    {
        string filename;
        String prodNameOnFile = product;
        if(product == BuyflowConstant.AMIS){
            prodNameOnFile = BuyflowConstant.MIS;
        }
        if(Mode == RDSExcelExportIndicesKeys.sk_MODE_A){
            filename =quotename+RDSExcelExportIndicesKeys.sk_ADDNAME+prodNameOnFile+RDSExcelExportIndicesKeys.sk_underscore+RDSExcelExportIndicesKeys.sk_RDS_SITES+RDSExcelExportIndicesKeys.sk_RDS_EXTENSION; 
        }
        else{
            if(ipflexDeal == SpecialCharacterConstant.TRUE_LITERAL){
                filename =quotename+RDSExcelExportIndicesKeys.sk_NEWNAME+prodNameOnFile+RDSExcelExportIndicesKeys.sk_underscore+RDSExcelExportIndicesKeys.ipFlexFileName+RDSExcelExportIndicesKeys.sk_RDS_SITES+RDSExcelExportIndicesKeys.sk_RDS_EXTENSION; 
            }
            else{
                filename =quotename+RDSExcelExportIndicesKeys.sk_NEWNAME+prodNameOnFile+RDSExcelExportIndicesKeys.sk_underscore+RDSExcelExportIndicesKeys.sk_RDS_SITES+RDSExcelExportIndicesKeys.sk_RDS_EXTENSION; 
            }
            
        }
        Excelname = filename;
    }                          
    
    /*
    * Name: fetchRDSData
    */
    public void fetchRDSData(String premiseIds,String remarks,String notes){
        Set<String> vlanIds = new Set<String>();
        String jackType=SpecialCharacterConstant.CONCAT;
        string ipv4Exception = SpecialCharacterConstant.CONCAT;
        if(premiseIds != null ){
            cktVlanDetailsList = [Select Jack_Type__c,IPv4_Exception__c, Site_interface__c,Provising_Access_Arrangement_Code__c,Domain_Name__c,Top_Level_Domain_Name__c,Transport_Type__c,Access_Method__c,Premise__r.VLAN_Count__c,PAA_Code__c,Premise__r.id,Premise__r.Transport_Type__c,VPN_Name_CVLAN__c,VLAN_Tag_Control__c,Arrangement_Code__c,
                                  Access_Provider_Name__c,IP_Version__c,ETHToken__c,ATT_POP_CLLI__c,SWC_CLLI__c,Unilink_Indicator__c,Contracted_Port_Speed__c,Hi_Cap_Flex_Minimum_Bandwidth_Commitment__c,Access_Speed__c,Class_of_Service_Package__c,Ingress_COS_Profile_ID__c,
                                  Egress_COS_Profile_ID__c,(Select id,RDS_Circuit_and_VLAN_Details_V4__c from RDS_V4_Family_Data__r) From Circuit_and_VLAN_Details__c Where Premise__c =:premiseIds];  
            for(Circuit_and_VLAN_Details__c cvlans : cktVlanDetailsList){
           jackType=cvlans.jack_type__c;
           ipv4Exception = cvlans.IPv4_Exception__c;
            
                cvlanIds.add(cvlans.id);
                if(cvlans.Premise__r.id == premiseIds){
                    loadDataOnWRC(RDSExcelExportIndicesKeys.Transport_Type,cvlans.Transport_Type__c,sectionColId,premisesectionName);
                    if(cvlans.Transport_Type__c == RDSExcelExportIndicesKeys.sk_SwitchedEthernet){
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Interface_Type,cvlans.Site_interface__c,sectionColId,premisesectionName);
                    }
                    loadDataOnWRC(RDSExcelExportIndicesKeys.Vlan_Tag_Control,cvlans.VLAN_Tag_Control__c,sectionColId,premisesectionName);
                    if(product == BuyflowConstant.AVPN){
                        loadDataOnWRC(RDSExcelExportIndicesKeys.PORT_VPN_Name,cvlans.VPN_Name_CVLAN__c,sectionColId,premisesectionName);
                        
                    } 
                    else if(product == BuyflowConstant.AMIS) { 
                        domainURLfromObj = cvlans.Domain_Name__c+'.'+cvlans.Top_Level_Domain_Name__c;
                        domainId = cvlans.Domain_Name__c;
                        if(cvlans.Domain_Name__c == null && cvlans.Top_Level_Domain_Name__c == null){
                            domainURLfromObj = SpecialCharacterConstant.CONCAT;
                        }
                        loadDataOnWRC(RDSExcelExportIndicesKeys.PREMISE_Domain_URL,domainURLfromObj,sectionColId,premisesectionName);
                        loadDataOnWRC(RDSExcelExportIndicesKeys.How_Many_Usable_IP_Addresses,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);
                        if(cvlans.Domain_Name__c != null && cvlans.Domain_Name__c != SpecialCharacterConstant.CONCAT){ 
                            loadDataOnWRC(RDSExcelExportIndicesKeys.PREMISE_ATT_Hosted_DNS,BuyflowConstant.YES,sectionColId,premisesectionName);
                        }
                        else{
                            loadDataOnWRC(RDSExcelExportIndicesKeys.PREMISE_ATT_Hosted_DNS,BuyflowConstant.NO,sectionColId,premisesectionName);
                        }
                        if(cvlans.Class_of_Service_Package__c == BuyflowConstant.NOCOS1){
                            loadDataOnWRC(RDSExcelExportIndicesKeys.CoS_Requested,BuyflowConstant.NO,sectionColId,premisesectionName);
                        }
                        else{
                            loadDataOnWRC(RDSExcelExportIndicesKeys.CoS_Requested,BuyflowConstant.YES,sectionColId,premisesectionName);
                        }     
                    }
                    loadDataOnWRC(RDSExcelExportIndicesKeys.Provisioning_Access_Arrangement,cvlans.Arrangement_Code__c,sectionColId,premisesectionName);
                    loadDataOnWRC(RDSExcelExportIndicesKeys.Access_Provider,cvlans.Access_Provider_Name__c,sectionColId,premisesectionName);
                    if(cvlans.Transport_Type__c == RDSExcelExportIndicesKeys.sk_SwitchedEthernet){
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Access_Method_Type_Shared_Dedicated,RDSExcelExportIndicesKeys.sk_Shared,sectionColId,premisesectionName);
                    }
                    
                    loadDataOnWRC(RDSExcelExportIndicesKeys.Ethernet_Token,cvlans.ETHToken__c,sectionColId,premisesectionName);
                    loadDataOnWRC(RDSExcelExportIndicesKeys.IP_Type,cvlans.IP_Version__c,sectionColId,premisesectionName);
                    loadDataOnWRC(RDSExcelExportIndicesKeys.POP_CLLI,cvlans.ATT_POP_CLLI__c,sectionColId,premisesectionName);
                    loadDataOnWRC(RDSExcelExportIndicesKeys.SWC_CLLI,cvlans.SWC_CLLI__c,sectionColId,premisesectionName);
                    if(product == BuyflowConstant.AVPN){
                        if(cvlans.Unilink_Indicator__c == RDSExcelExportIndicesKeys.sk_true){
                            loadDataOnWRC(RDSExcelExportIndicesKeys.VLANs,RDSExcelExportIndicesKeys.sk_Yes,sectionColId,premisesectionName);
                        }else{
                            loadDataOnWRC(RDSExcelExportIndicesKeys.VLANs,RDSExcelExportIndicesKeys.sk_No,sectionColId,premisesectionName);
                        }
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Number_of_VLANs,String.valueof(cvlans.Premise__r.VLAN_Count__c),sectionColId,premisesectionName);
                    }
                    loadDataOnWRC(RDSExcelExportIndicesKeys.Port_Speed,cvlans.Contracted_Port_Speed__c,sectionColId,premisesectionName);
                    if(cvlans.Hi_Cap_Flex_Minimum_Bandwidth_Commitment__c == RDSExcelExportIndicesKeys.sk_DOUBLE_QOUTES || cvlans.Hi_Cap_Flex_Minimum_Bandwidth_Commitment__c == null){
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Port_Billing_Option,RDSExcelExportIndicesKeys.skFixed,sectionColId,premisesectionName);  
                    }else{
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Port_Billing_Option,RDSExcelExportIndicesKeys.sk_HiCapFlex,sectionColId,premisesectionName);     
                    }                                       
                    loadDataOnWRC(RDSExcelExportIndicesKeys.Minimum_Bandwidth_Commitment,cvlans.Hi_Cap_Flex_Minimum_Bandwidth_Commitment__c,sectionColId,premisesectionName);
                    loadDataOnWRC(RDSExcelExportIndicesKeys.Access_Speed,cvlans.Access_Speed__c,sectionColId,premisesectionName);
                    loadDataOnWRC(RDSExcelExportIndicesKeys.Class_of_Service_Package,cvlans.Class_of_Service_Package__c,sectionColId,premisesectionName);
                    loadDataOnWRC(RDSExcelExportIndicesKeys.Ingress_CoS_profile_ID,cvlans.Ingress_COS_Profile_ID__c,sectionColId,premisesectionName);
                    loadDataOnWRC(RDSExcelExportIndicesKeys.Egress_CoS_profile_ID,cvlans.Egress_COS_Profile_ID__c,sectionColId,premisesectionName);
                    if(product == BuyflowConstant.AVPN){
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Is_this_HUB_Site,RDSExcelExportIndicesKeys.sk_No,sectionColId,premisesectionName);
                    }
                } 
                fetchCvlanV4V6Data(cvlans.id);                        
                fetchVlanInfoData(cvlans.id,premiseIds);                     
            }
            String additionalInfo = SpecialCharacterConstant.CONCAT;
            if (String.isBlank(notes) && String.isBlank(jackType) && String.isBlank(ipv4Exception)){
                        additionalInfo = ' ';
                    }
            else{
                if(!String.isBlank(notes)){
                        additionalInfo = notes;
                }
                if(!String.isBlank(ipv4Exception)){
                    additionalInfo = additionalInfo + ', IPv4 Exception:  ' + ipv4Exception;
                }
                if(!String.isBlank(jackType)){
                    additionalInfo = additionalInfo + ', Jack Type: '  + jacktype;
                }
                if(additionalInfo.startsWith(' ,')){
                    additionalInfo = additionalInfo.removeStart(' ,');
                }else if(additionalInfo.startsWith(',')){
                    additionalInfo = additionalInfo.removeStart(',');
                }  
                if(additionalInfo.endsWith(',')){
                    additionalInfo = additionalInfo.removeEnd(',');
                }
            }    
    loadDataOnWRC(RDSExcelExportIndicesKeys.Additional_Information_ASR_Installation_Notes,additionalInfo,sectionColId,premisesectionName);                                                   
        }
    }
    
    /*
    * Name: fetchCvlanV4V6Data
    */
    public void fetchCvlanV4V6Data(Id cvlans){
        Id vlans;
        v4FamilyList = [Select id,Routing_Protocol__c,Customer_Edge_IP_Address__c,ATT_Edge_IP_Address__c,Subnet_Mask__c,Routing_ASN__c,ASN_Override_Indicator__c,Route_Advertisement__c,Packet_Filter__c,Send_Default_Indicator__c,Encrypted_Password__c,RDS_Circuit_and_VLAN_Details_V4__c,RDS_Circuit_and_VLAN_Details_V4__r.id from RDS_V4_Family_Data__c where RDS_Circuit_and_VLAN_Details_V4__c =: cvlans ];
        v6familyList = [Select id,Routing_Protocol__c,Local_ASN__c,Customer_Edge_IP_Address__c,ATT_Edge_IP_Address__c,Routing_ASN__c,Send_Default_Indicator__c,Route_Advertisement__c,AS_Override_Indicator__c,Packet_Fillter__c,Encrypted_Password__c,RDS_Circuit_and_VLAN_Details_V6__c,RDS_Circuit_and_VLAN_Details_V6__r.id from V6_Family_Data__c where RDS_Circuit_and_VLAN_Details_V6__c =: cvlans ];
        if(v4FamilyList != null && v4FamilyList.size()>0){
            for(RDS_V4_Family_Data__c v4data : v4FamilyList){
                if(v4data.RDS_Circuit_and_VLAN_Details_V4__r.id != null && v4data.RDS_Circuit_and_VLAN_Details_V4__r.id == cvlans){
                    loadDataOnWRC(RDSExcelExportIndicesKeys.Routing_Protocol_V4,v4data.Routing_Protocol__c,sectionColId,premisesectionName);                               
                    if(product == BuyflowConstant.AVPN){
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Customer_Edge_IP_Address_V4,v4data.Customer_Edge_IP_Address__c,sectionColId,premisesectionName);
                        loadDataOnWRC(RDSExcelExportIndicesKeys.ATT_Edge_IP_Address_V4,v4data.ATT_Edge_IP_Address__c,sectionColId,premisesectionName);
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Subnet_Mask_V4,v4data.Subnet_Mask__c,sectionColId,premisesectionName);
                    }
                    else if(product == BuyflowConstant.AMIS){
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Route_Advertisement_V4,v4data.Route_Advertisement__c,sectionColId,premisesectionName);
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Packet_Filter_V4,v4data.Packet_Filter__c,sectionColId,premisesectionName);
                    } 
                        
                    if(v4data.Routing_Protocol__c.contains(MACDConstant.BGP)){
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Autonomous_System_Number_V4,v4data.Routing_ASN__c,sectionColId,premisesectionName);
                        if(product == BuyflowConstant.AVPN){
                            loadDataOnWRC(RDSExcelExportIndicesKeys.Autonomous_System_Number_Override_V4,v4data.ASN_Override_Indicator__c,sectionColId,premisesectionName);
                        }
                        if(v4data.Send_Default_Indicator__c == RDSExcelExportIndicesKeys.sk_true){
                            loadDataOnWRC(RDSExcelExportIndicesKeys.Restrictive_Routing_Send_Default_V4,RDSExcelExportIndicesKeys.sk_Yes,sectionColId,premisesectionName);
                        }else{
                            loadDataOnWRC(RDSExcelExportIndicesKeys.Restrictive_Routing_Send_Default_V4,RDSExcelExportIndicesKeys.sk_No,sectionColId,premisesectionName);
                        }                                
                    }
                    loadDataOnWRC(RDSExcelExportIndicesKeys.MD5_Authentication_encrypted_password_V4,v4data.Encrypted_Password__c,sectionColId,premisesectionName);
                } 
            }   
        }   
        
        fetchIpAddressForCvlan(cvlans,BuyflowConstant.V4);
        if(v6familyList != null && v6familyList.size()>0){                                   
            for(V6_Family_Data__c v6data : v6familyList){
                if(v6data.RDS_Circuit_and_VLAN_Details_V6__r.id == cvlans){
                    if(product == BuyflowConstant.AMIS){
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Route_Advertisement_V6,v6data.Route_Advertisement__c,sectionColId,premisesectionName);
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Packet_Filter_V6,v6data.Packet_Fillter__c,sectionColId,premisesectionName);
                    }
                    loadDataOnWRC(RDSExcelExportIndicesKeys.Routing_Protocol_V6,v6data.Routing_Protocol__c,sectionColId,premisesectionName);
                    if(v6data.Routing_Protocol__c.contains(MACDConstant.BGP)){
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Autonomous_System_Number_V6,v6data.Routing_ASN__c,sectionColId,premisesectionName);
                        if(product == BuyflowConstant.AVPN){
                            loadDataOnWRC(RDSExcelExportIndicesKeys.Autonomous_System_Number_Override_V6,v6data.AS_Override_Indicator__c,sectionColId,premisesectionName);
                        }
                        if(v6data .Send_Default_Indicator__c == RDSExcelExportIndicesKeys.sk_true){
                            loadDataOnWRC(RDSExcelExportIndicesKeys.Restrictive_Routing_Send_Default_V6,RDSExcelExportIndicesKeys.sk_Yes,sectionColId,premisesectionName);
                        }else{
                            loadDataOnWRC(RDSExcelExportIndicesKeys.Restrictive_Routing_Send_Default_V6,RDSExcelExportIndicesKeys.sk_No,sectionColId,premisesectionName);
                        }
                    }
                    loadDataOnWRC(RDSExcelExportIndicesKeys.Local_ASN_V6,v6data.Local_ASN__c,sectionColId,premisesectionName);  
                    loadDataOnWRC(RDSExcelExportIndicesKeys.MD5_Authentication_encrypted_password_V6,v6data.Encrypted_password__c,sectionColId,premisesectionName);                                  
                }
            } 
        } 
        
        fetchIpAddressForCvlan(cvlans,BuyflowConstant.V6);              
    }
    
    /*
    * Name: fetchV4V6FamilyData
    */
    public void fetchV4V6FamilyData(Set<String> vIds,String type ){
        Map<Integer,String> v4LanIPMap = new Map<Integer,String>();
        v4LANIPAddressList = new List<RDS_V4_LAN_IP_Address__c>();
        v6LANIPAddressList = new List<RDS_V6_LAN_IP_Address__c>();
        if(type==MACDConstant.V41){
            v4LANIPAddressList = [Select Id,IP_Address__c,Address_Mask__c FROM RDS_V4_LAN_IP_Address__c WHERE Id IN: vIds]; 
            Integer i = 0;
            for(RDS_V4_LAN_IP_Address__c v4LanIp : v4LANIPAddressList){
                loadDataOnWRC(RDSExcelExportIndicesKeys.LAN_Address_Address_Mask+i,v4LanIp.IP_Address__c,sectionColId,premisesectionName); 
                i++;
            }
        }else  if(type==MACDConstant.V61){
            v6LANIPAddressList = [Select Id,IP_Address__c,Length__c FROM RDS_V6_LAN_IP_Address__c WHERE Id IN: vIds];
            Integer i = 0;
            for(RDS_V6_LAN_IP_Address__c v4LanIp : v6LANIPAddressList){
                loadDataOnWRC(RDSExcelExportIndicesKeys.LAN_Address_Address_Mask+i,v4LanIp.IP_Address__c,sectionColId,premisesectionName); 
                i++;
            }
        }
    }
    
    /*
    * Name: fetchVlanInfoData
    */
    public void fetchVlanInfoData(Id cvlans,String premiseIds){
        Set<String> v4FamilyIdSet = new Set<String>();
        Set<String> v6FamilyIdSet = new Set<String>();
        if(cvlans != null){
            rdsVlanInfo = [Select id,VPN_Name__c,Circuit_and_VLAN_Details__c,Circuit_and_VLAN_Details__r.Premise__r.id,VLAN_Speed__c,Ingress_COS_Profile_ID__c,Egress_COS_Profile_ID__c,Address_Type__c,Circuit_and_VLAN_Details__r.id from VLAN_Information__c where Circuit_and_VLAN_Details__c =: cvlans];
            for(VLAN_Information__c rdsVlanInfo : rdsVlanInfo){
                vlaninfoIds.add(rdsVlanInfo.id);
            }
            if(rdsVlanInfo != null && rdsVlanInfo.size()>0){
                v4familyListVLAN = [SELECT Id,RDS_VLAN_Information_V4__r.id,RDS_VLAN_Information_V4__c,Routing_Protocol__c,Route_Advertisement__c,Packet_Filter__c,Customer_Edge_IP_Address__c,ATT_Edge_IP_Address__c,Subnet_Mask__c,Routing_ASN__c,ASN_Override_Indicator__c,Send_Default_Indicator__c,Encrypted_Password__c FROM RDS_V4_Family_Data__c WHERE RDS_VLAN_Information_V4__c =: vlaninfoIds];
                v6familyListVLAN = [Select id,RDS_VLAN_Information__r.id,Routing_Protocol__c,Local_ASN__c,Customer_Edge_IP_Address__c,ATT_Edge_IP_Address__c,Route_Advertisement__c,Packet_Fillter__c,Routing_ASN__c,Send_Default_Indicator__c,AS_Override_Indicator__c,Encrypted_Password__c,RDS_Circuit_and_VLAN_Details_V6__c,RDS_VLAN_Information__c from V6_Family_Data__c where RDS_VLAN_Information__c =: vlaninfoIds];
                Integer i = 1;
                for(VLAN_Information__c rdsVlan : rdsVlanInfo){
                    if(rdsVlan.Circuit_and_VLAN_Details__r.id == cvlans && rdsVlan.Circuit_and_VLAN_Details__r.Premise__r.id == premiseIds) {
                        if(product == BuyflowConstant.AVPN){
                            loadDataOnWRC(RDSExcelExportIndicesKeys.Is_this_HUB_VLAN+i,RDSExcelExportIndicesKeys.sk_No,sectionColId,premisesectionName); 
                            if(flowtype == 'New Start') {
                                loadDataOnWRC(RDSExcelExportIndicesKeys.VPN_Status_VLAN+i,SpecialCharacterBuyflowConstant.NEW_CAPS_LITERAL,sectionColId,premisesectionName);
                            }
                            else{
                                loadDataOnWRC(RDSExcelExportIndicesKeys.VPN_Status_VLAN+i,BuyflowConstant.EXISTING_VALIDATE_VPNNAME_CONST,sectionColId,premisesectionName);
                            }
                            loadDataOnWRC(RDSExcelExportIndicesKeys.VPN_Name_VLAN+i,rdsVlan.VPN_Name__c,sectionColId,premisesectionName);
                        }
                        if(product == BuyflowConstant.AVPN || (product == BuyflowConstant.AMIS && i==1)){
                            loadDataOnWRC(RDSExcelExportIndicesKeys.VLAN_Speed_VLAN+i,rdsVlan.VLAN_Speed__c,sectionColId,premisesectionName);
                        }
                        if(product == BuyflowConstant.AVPN){
                            loadDataOnWRC(RDSExcelExportIndicesKeys.VPN_Multicast_Enabled_VLAN+i,RDSExcelExportIndicesKeys.sk_No,sectionColId,premisesectionName);
                        } 
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Ingress_CoS_profile_ID_VLAN+i,rdsVlan.Ingress_COS_Profile_ID__c,sectionColId,premisesectionName);
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Egress_CoS_profile_ID_VLAN+i,rdsVlan.Egress_COS_Profile_ID__c,sectionColId,premisesectionName);
                        loadDataOnWRC(RDSExcelExportIndicesKeys.IP_Type_VLAN+i,rdsVlan.Address_Type__c,sectionColId,premisesectionName);
                        for(RDS_V4_Family_Data__c v4dataVlan : v4familyListVLAN){
                            v4FamilyIdSet.add(v4dataVlan.Id);
                            if(v4dataVlan.RDS_VLAN_Information_V4__r.id == rdsVlan.id){
                                loadDataOnWRC(RDSExcelExportIndicesKeys.Routing_Protocol_V4_VLAN+i,v4dataVlan.Routing_Protocol__c,sectionColId,premisesectionName);
                                if(product == BuyflowConstant.AVPN){
                                    loadDataOnWRC(RDSExcelExportIndicesKeys.Customer_Edge_IP_Address_V4_VLAN+i,v4dataVlan.Customer_Edge_IP_Address__c,sectionColId,premisesectionName);
                                    loadDataOnWRC(RDSExcelExportIndicesKeys.ATT_Edge_IP_Address_V4_VLAN+i,v4dataVlan.ATT_Edge_IP_Address__c,sectionColId,premisesectionName);
                                    loadDataOnWRC(RDSExcelExportIndicesKeys.Subnet_Mask_V4_VLAN+i,v4dataVlan.Subnet_Mask__c,sectionColId,premisesectionName);
                                }
                                else if(product == BuyflowConstant.AMIS && i == 1){
                                    loadDataOnWRC(RDSExcelExportIndicesKeys.Route_Advertisement_V4_VLAN,v4dataVlan.Route_Advertisement__c,sectionColId,premisesectionName);                       
                                    loadDataOnWRC(RDSExcelExportIndicesKeys.Packet_Filter_V4_VLAN,v4dataVlan.Packet_Filter__c,sectionColId,premisesectionName);                       
                                }
                                if(v4dataVlan.Routing_Protocol__c !=null && v4dataVlan.Routing_Protocol__c.contains(MACDConstant.BGP)){
                                    loadDataOnWRC(RDSExcelExportIndicesKeys.Autonomous_System_Number_V4_VLAN+i,v4dataVlan.Routing_ASN__c,sectionColId,premisesectionName);
                                    if(product == BuyflowConstant.AVPN){
                                        loadDataOnWRC(RDSExcelExportIndicesKeys.Autonomous_System_Number_Override_V4_VLAN+i,v4dataVlan.ASN_Override_Indicator__c,sectionColId,premisesectionName);
                                    }
                                    if(product == BuyflowConstant.AVPN || (product==BuyflowConstant.AMIS && i ==1)){
                                        loadDataOnWRC(RDSExcelExportIndicesKeys.Restrictive_Routing_Send_Default_V4_VLAN+i,v4dataVlan.Send_Default_Indicator__c,sectionColId,premisesectionName);
                                        loadDataOnWRC(RDSExcelExportIndicesKeys.MD5_Authentication_encrypted_password_V4_VLAN+i,v4dataVlan.Encrypted_Password__c,sectionColId,premisesectionName);
                                    }
                                }
                                populateAddressMask(rdsVlan.id,i,BuyflowConstant.V4,false);
                            }
                        }
                        for(V6_Family_Data__c v6dataVlan : v6familyListVLAN ){
                            v6FamilyIdSet.add(v6dataVlan.Id);
                            if(v6dataVlan.RDS_VLAN_Information__r.id == rdsVlan.id){
                                if(product == BuyflowConstant.AMIS && i == 1){
                                    loadDataOnWRC(RDSExcelExportIndicesKeys.Route_Advertisement_V6_VLAN+i,v6dataVlan.Route_Advertisement__c,sectionColId,premisesectionName);                       
                                    loadDataOnWRC(RDSExcelExportIndicesKeys.Packet_Filter_V6_VLAN+i,v6dataVlan.Packet_Fillter__c,sectionColId,premisesectionName);
                                }
                                if(product == BuyflowConstant.AVPN || (product == BuyflowConstant.AMIS && i == 1)){
                                    loadDataOnWRC(RDSExcelExportIndicesKeys.Routing_Protocol_V6_VLAN+i,v6dataVlan.Routing_Protocol__c,sectionColId,premisesectionName);
                                    if(v6dataVlan.Routing_Protocol__c !=null && v6dataVlan.Routing_Protocol__c.contains(MACDConstant.BGP)) {
                                        if(v6dataVlan.Routing_ASN__c != null && v6dataVlan.Routing_ASN__c != SpecialCharacterConstant.CONCAT){
                                            loadDataOnWRC(RDSExcelExportIndicesKeys.Autonomous_System_Number_V6_VLAN+i,v6dataVlan.Routing_ASN__c,sectionColId,premisesectionName); 
                                        }
                                        
                                        if(product == BuyflowConstant.AVPN){
                                            loadDataOnWRC(RDSExcelExportIndicesKeys.Autonomous_System_Number_Override_V6_VLAN+i,v6dataVlan.AS_Override_Indicator__c,sectionColId,premisesectionName);
                                        }
                                        loadDataOnWRC(RDSExcelExportIndicesKeys.Restrictive_Routing_Send_Default_V6_VLAN+i,v6dataVlan.Send_Default_Indicator__c,sectionColId,premisesectionName);
                                        loadDataOnWRC(RDSExcelExportIndicesKeys.MD5_Authentication_encrypted_password_V6_VLAN+i,v6dataVlan.Encrypted_Password__c ,sectionColId,premisesectionName);
                                    }
                                }
                                populateAddressMask(rdsVlan.id,i,BuyflowConstant.V6,false)   ;
                            }
                        }
                    }
                    i++;
                }
                for(;i<13;i++){
                    fillBlanksOnVlan(i);
                }                 
            }else {  for(integer g=1;g<13;g++){
            }
                  }             
        }
    }
    /*
    * Name: fillBlanksOnVlan
    */
    public void fillBlanksOnVlan(integer i){       
    }
    /*
    * Name: loadDataOnWRC
    */
    public void loadDataOnWRC(String dataKey, String data, Integer sectionColId,String  premisesectionName) {
        List<Integer> lsitIds;
        try{
            if(product == BuyflowConstant.AVPN){
                lsitIds=RDSExcelExportIndicesMap.exportIndicesMap.get(dataKey);
            }else if(product == BuyflowConstant.AMIS){
                lsitIds=MISRDSExcelExportIndicesMap.exportIndicesMap.get(dataKey);
            }
            if(lsitIds!=null && lsitIds.size()>0){
                for(Integer i=0;i<lsitIds.size();i++){
                    integer  colindex=lsitIds.get(i);
                    string sectionKey = SpecialCharacterConstant.CONCAT;
                    if(product == BuyflowConstant.AVPN){
                        SectionKey=RDSExcelExportMap.sectionKeys.get(colindex).get(0);
                    }else if(product == BuyflowConstant.AMIS){
                        SectionKey=MISRDSExcelExportMap.sectionKeys.get(colindex).get(0);
                    }
                    if(data==null){
                        data=RDSExcelExportIndicesKeys.sk_DOUBLE_QOUTES;
                    }
                    wrcb.loadSectionElementAsCoreMap(SectionKey,data,SectionKey+SpecialCharacterConstant.UNDERSCORE+colindex+SpecialCharacterConstant.UNDERSCORE+sectionColId,RDSExcelExportIndicesKeys.sk_DOUBLE_QOUTES+colindex,colindex,sectionColId,false);                           
                }
            }else {
                throw new applicationException (MACDConstant.SIVARConst_44999,BuyflowConstant.RDSEXCEL_ERROR_LOADDATA_CONST+lsitIds+BuyflowConstant.RDSEXCEL_ERROR_FOR_DATAKEY_CONST+dataKey+BuyflowConstant.RDSEXCEL_ERROR_FOR_DATA_CONST+data);
            }
        }catch(Exception e){
            applicationException  ae=    new applicationException (MACDConstant.SIVARConst_44999,BuyflowConstant.RDSEXCEL_ERROR_LOADDATA_EXCP_CONST+lsitIds+BuyflowConstant.RDSEXCEL_ERROR_FOR_DATAKEY_CONST+dataKey+BuyflowConstant.RDSEXCEL_ERROR_FOR_DATA_CONST+data+BuyflowConstant.RDSEXCEL_ERROR_AT_LINENUM_CONST+e.getLineNumber(),e);
            throw ae;
        }
    }
    
    /*
     * Name: attachExcel
     */
    public void attachExcel(){
        if(string.ISBLANK(quoteId)){
            quoteId = apexpages.currentpage().getParameters().get(RDSExcelExportIndicesKeys.sk_quoteId);
        }
        PageReference excelPage = new PageReference('/apex/RDSExcel?quoteId='+quoteId);
        OpptId = [Select Id,Apttus_Proposal__Opportunity__c,Name from Apttus_Proposal__Proposal__c where Id=: quoteId].Apttus_Proposal__Opportunity__c;
        Blob body;
        Attachment attach = new Attachment(); 
        attach.Body = excelPage.getContent();
        // add the user entered name
        attach.Name = BuyflowConstant.QUOTE_EXPORT_FILENAME_CONST;
        attach.IsPrivate = false;
        // attach the pdf to the account
        attach.ParentId = OpptID;
        if(AttList != NULL){
            AttList.add(attach); 
        }    
        insert  AttList;               
    }
    
    /*
     * Name: populateAddressMask
     */
    public void populateAddressMask(Id rdsVlan,integer k,String ipType,boolean isblank) {
        if(ipType==BuyflowConstant.V4){
            integer x=1;
            if(!isblank){
                v4IPAddressList  = new List<RDS_V4_LAN_IP_Address__c>();
                if(rdsVlan != null){
                    v4IPAddressList = [SELECT Id,IP_Address__c,Address_Mask__c,Length__c, RDS_V4_Family_Data__r.RDS_VLAN_Information_V4__r.id FROM RDS_V4_LAN_IP_Address__c WHERE RDS_V4_Family_Data__r.RDS_VLAN_Information_V4__r.id =: rdsVlan];
                }
                for(RDS_V4_LAN_IP_Address__c v4add: v4IPAddressList ){
                    String ipAddVl = SpecialCharacterConstant.CONCAT;
                    String addMask = SpecialCharacterConstant.CONCAT;
                    String len = SpecialCharacterConstant.CONCAT;
                    if(v4add.IP_Address__c != null){
                        IpAddVl = v4add.IP_Address__c;
                    }
                    if(v4add.Address_Mask__c != null){
                        AddMask = v4add.Address_Mask__c;
                    }
                    if(v4add.Length__c != null){
                        Len = v4add.Length__c;
                    }
                    if(product == BuyflowConstant.AVPN){
                        loadDataOnWRC(RDSExcelExportIndicesKeys.LAN_Address_Address_Mask+x+BuyflowConstant.V4_VLAN_CONST+k,IpAddVl+SpecialCharacterConstant.ONLY_SLASH+AddMask,sectionColId,premisesectionName);                
                    }     
                    else if(product == BuyflowConstant.AMIS && k == 1){
                        loadDataOnWRC(RDSExcelExportIndicesKeys.LAN_Address_Address_Mask+x+BuyflowConstant.V4_VLAN_CONST+k,IpAddVl+SpecialCharacterConstant.ONLY_SLASH+Len,sectionColId,premisesectionName);                
                    }              
                    x++;   
                }}
            
        }
        if(ipType==BuyflowConstant.V6){
            integer z=1; 
            if(!isblank){
                v6IPAddressList  = new List<RDS_V6_LAN_IP_Address__c>();
                if(rdsVlan != null){
                    v6IPAddressList = [SELECT Id,IP_Address__c,Length__c, RDS_V6_Family_Data__r.RDS_VLAN_Information__r.id FROM RDS_V6_LAN_IP_Address__c WHERE RDS_V6_Family_Data__r.RDS_VLAN_Information__r.id =: rdsVlan];
                } 
                for(RDS_V6_LAN_IP_Address__c v6add: v6IPAddressList ){
                    if(product == BuyflowConstant.AVPN || (product == BuyflowConstant.AMIS && k==1)){
                        String ipAddVl = SpecialCharacterConstant.CONCAT;
                        String len = SpecialCharacterConstant.CONCAT;
                        if(v6add.IP_Address__c != null){
                            IpAddVl = v6add.IP_Address__c;
                        }
                        if(v6add.Length__c != null){
                            Len = v6add.Length__c;
                        }
                        loadDataOnWRC(RDSExcelExportIndicesKeys.LAN_Address_Address_Mask+z+BuyflowConstant.V6_VLAN_CONST+k,IpAddVl+SpecialCharacterConstant.ONLY_SLASH+Len,sectionColId,premisesectionName);                          
                    }
                    z++;     
                }
            }
            
        }
    }
    
    /*
     * Name: fetchIpAddressForCvlan
     */
    public void fetchIpAddressForCvlan(Id cvlans,String ipType){
        if(cvlans != null){
            if(ipType==BuyflowConstant.V4){
                v4IPAddressList = [SELECT Id,IP_Address__c,Length__c,RDS_V4_Family_Data__r.RDS_Circuit_and_VLAN_Details_V4__r.id,Address_Mask__c FROM RDS_V4_LAN_IP_Address__c WHERE RDS_V4_Family_Data__r.RDS_Circuit_and_VLAN_Details_V4__r.id =: cvlans];
            }
            else if(ipType==BuyflowConstant.V6){ 
                v6IPAddressList = [SELECT Id,IP_Address__c,Length__c,RDS_V6_Family_Data__r.RDS_Circuit_and_VLAN_Details_V6__r.id FROM RDS_V6_LAN_IP_Address__c WHERE RDS_V6_Family_Data__r.RDS_Circuit_and_VLAN_Details_V6__r.id =: cvlans];
            }
            for(Integer i=1;i<21;i++){  
                if(ipType==BuyflowConstant.V4){
                    if(v4IPAddressList.size() >= i && v4IPAddressList.size() >0){
                        if((v4IPAddressList[i-1].IP_Address__c != null && v4IPAddressList[i-1].IP_Address__c != RDSExcelExportIndicesKeys.sk_DOUBLE_QOUTES)||(v4IPAddressList[i-1].Address_Mask__c != null && v4IPAddressList[i-1].Address_Mask__c != RDSExcelExportIndicesKeys.sk_DOUBLE_QOUTES)||(v4IPAddressList[i-1].Length__c != null && v4IPAddressList[i-1].Length__c != RDSExcelExportIndicesKeys.sk_DOUBLE_QOUTES)){
                            String addMask1 = SpecialCharacterConstant.CONCAT;
                            String addMask2 = SpecialCharacterConstant.CONCAT;
                            String len = SpecialCharacterConstant.CONCAT;
                            if(v4IPAddressList[i-1].IP_Address__c != null){
                                AddMask1 =v4IPAddressList[i-1].IP_Address__c;
                            }
                            if(v4IPAddressList[i-1].Address_Mask__c != null){
                                AddMask2 =v4IPAddressList[i-1].Address_Mask__c;
                            }
                            if(v4IPAddressList[i-1].Length__c != null){
                                Len = v4IPAddressList[i-1].Length__c;
                            }
                            if(product == BuyflowConstant.AVPN){
                                loadDataOnWRC(RDSExcelExportIndicesKeys.LAN_Address_Address_Mask+i+BuyflowConstant.UNDERSCORE_V4_CONST,AddMask1+SpecialCharacterConstant.ONLY_SLASH+AddMask2,sectionColId,premisesectionName);
                            }           
                            else{
                                loadDataOnWRC(RDSExcelExportIndicesKeys.LAN_Address_Address_Mask+i+BuyflowConstant.UNDERSCORE_V4_CONST,AddMask1+SpecialCharacterConstant.ONLY_SLASH+Len,sectionColId,premisesectionName);                          
                            }
                        }              
                        
                    }                 
                    
                }
                if(ipType==BuyflowConstant.V6){ 
                    if(v6IPAddressList.size() >= i && v6IPAddressList.size() >0){
                        String addMask1 = SpecialCharacterConstant.CONCAT;
                        String len= SpecialCharacterConstant.CONCAT;
                        if(v6IPAddressList[i-1].IP_Address__c != null){
                            AddMask1 =v6IPAddressList[i-1].IP_Address__c;
                        }
                        if(v6IPAddressList[i-1].Length__c != null){
                            Len = v6IPAddressList[i-1].Length__c;
                        }
                        loadDataOnWRC(RDSExcelExportIndicesKeys.LAN_Address_Address_Mask+i+BuyflowConstant.UNDERSCORE_V6_CONST,AddMask1+SpecialCharacterConstant.ONLY_SLASH+Len,sectionColId,premisesectionName);
                    } 
                }
            }  
        }                                                                               
    }
    
    
    /*
     * Name: fetchIPFlexDetails
     * Below method is for ipflex details. Last Edited on 19th May 2016
    */
    public void fetchIPFlexDetails(String premiseId, String premiseNumber){

        if(ipflexDeal == SpecialCharacterConstant.TRUE_CAMEL_LITERAL || misplus){
            if(product == BuyflowConstant.AMIS){
                if(addDNSfromSPP != null && addDNSfromSPP.size()>0){
                    for(SPProduct__c sprod : addDNSfromSPP){
                        if(sprod.Site_ID__c == premiseNumber){
                            if(sprod.Additional_DNS__c != null && IPFlexPlanMap.get(premiseNumber) != null){
                                loadDataOnWRC(BuyflowConstant.WILL_AT_AND_T_BE_DOING_ADDITONAL_DNS_CONST,sprod.Additional_DNS__c,sectionColId,premisesectionName);
                            }
                            else{
                                loadDataOnWRC(BuyflowConstant.WILL_AT_AND_T_BE_DOING_ADDITONAL_DNS_CONST,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);
                            }
                        } 
                    }
                }
            }
        if(premiseDetailsIpfDetailsList != null && premiseDetailsIpfDetailsList.size() > 0){
            for(RDS_IPFlex_Details__c ipflexSite : premiseDetailsIpfDetailsList){
                if(ipflexSite.RDS_Premise_Details__c == premiseId){
                    //Fields only for AVPN 
                    if(product == BuyflowConstant.AVPN){
                        if(ipflexSite.VQM_Type__c  != null){           
                            loadDataOnWRC(RDSExcelExportIndicesKeys.Type_of_VQM,ipflexSite.VQM_Type__c,sectionColId,premisesectionName);
                        }
                        else{
                            loadDataOnWRC(RDSExcelExportIndicesKeys.Type_of_VQM,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                        }
                        if(ipflexSite.CODEC__c!= null){           
                            loadDataOnWRC(RDSExcelExportIndicesKeys.If_CPE_rquires_fax,ipflexSite.CODEC__c,sectionColId,premisesectionName);
                        }
                        else{
                            loadDataOnWRC(RDSExcelExportIndicesKeys.If_CPE_rquires_fax,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                        }
                        if(ipflexSite.CE_Router_Vendor_or_Mfg__c!= null){           
                            loadDataOnWRC(RDSExcelExportIndicesKeys.CE_Router_Vendor_Mfg,ipflexSite.CE_Router_Vendor_or_Mfg__c,sectionColId,premisesectionName);
                        }
                        else{
                            loadDataOnWRC(RDSExcelExportIndicesKeys.CE_Router_Vendor_Mfg,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                        }
                        if(ipflexSite.CE_Router_Model__c!= null){           
                            loadDataOnWRC(RDSExcelExportIndicesKeys.CE_Router_Model,ipflexSite.CE_Router_Model__c,sectionColId,premisesectionName);
                        }
                        else{
                            loadDataOnWRC(RDSExcelExportIndicesKeys.CE_Router_Model,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                        }
                        if(ipflexSite.CE_Router_Software_Version__c!= null){           
                            loadDataOnWRC(RDSExcelExportIndicesKeys.CE_Router_Software_Version,ipflexSite.CE_Router_Software_Version__c,sectionColId,premisesectionName);
                        }
                        else{
                            loadDataOnWRC(RDSExcelExportIndicesKeys.CE_Router_Software_Version,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                        }
                        if(ipflexSite.SBC_cascaded_integrated_with_CE_Router__c!= null){           
                            loadDataOnWRC(RDSExcelExportIndicesKeys.SBC_cascaded_integrated_with_CE_Router,ipflexSite.SBC_cascaded_integrated_with_CE_Router__c,sectionColId,premisesectionName);
                        }
                        else{
                            loadDataOnWRC(RDSExcelExportIndicesKeys.SBC_cascaded_integrated_with_CE_Router,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                        }
                        if(ipflexSite.SBC_Vendor__c!= null){           
                            loadDataOnWRC(RDSExcelExportIndicesKeys.SBC_Vendor,ipflexSite.SBC_Vendor__c,sectionColId,premisesectionName);
                        }
                        else{
                            loadDataOnWRC(RDSExcelExportIndicesKeys.SBC_Vendor,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                        }
                        if(ipflexSite.SBC_Name__c!= null){           
                            loadDataOnWRC(RDSExcelExportIndicesKeys.SBC_Name,ipflexSite.SBC_Name__c,sectionColId,premisesectionName);
                        }
                        else{
                            loadDataOnWRC(RDSExcelExportIndicesKeys.SBC_Name,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                        }
                        if(ipflexSite.SBC_Software_Version__c!= null){           
                            loadDataOnWRC(RDSExcelExportIndicesKeys.SBC_Software_Version,ipflexSite.SBC_Software_Version__c,sectionColId,premisesectionName);
                        }
                        else{
                            loadDataOnWRC(RDSExcelExportIndicesKeys.SBC_Software_Version,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                        }
                        if(ipflexSite.Number_of_SBCs_for_the_site__c!= null){           
                            loadDataOnWRC(RDSExcelExportIndicesKeys.Number_of_SBCs_for_the_site,ipflexSite.Number_of_SBCs_for_the_site__c,sectionColId,premisesectionName);
                        }
                        else{
                            loadDataOnWRC(RDSExcelExportIndicesKeys.Number_of_SBCs_for_the_site,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                        }
                        if(ipflexSite.IVR_Vendor_Model_Name_Release_Version__c!= null){           
                            loadDataOnWRC(RDSExcelExportIndicesKeys.IVR_Vendor_Model_Name_Release_Version,ipflexSite.IVR_Vendor_Model_Name_Release_Version__c,sectionColId,premisesectionName);
                        }
                        else{
                            loadDataOnWRC(RDSExcelExportIndicesKeys.IVR_Vendor_Model_Name_Release_Version,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                        }
                        if(ipflexSite.IVR_behind_the_PBX_or_Standalone__c!= null){           
                            loadDataOnWRC(RDSExcelExportIndicesKeys.IVR_behind_the_PBX_or_Standalone,ipflexSite.IVR_behind_the_PBX_or_Standalone__c,sectionColId,premisesectionName);
                        }
                        else{
                            loadDataOnWRC(RDSExcelExportIndicesKeys.IVR_behind_the_PBX_or_Standalone,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                        }
                        if(ipflexSite.Req_to_sup_IPFlex_on_AVPN_Outside_Move__c != null){           
                            loadDataOnWRC(RDSExcelExportIndicesKeys.Request_to_support_IP_Flex_Reach_on_AVPN_Outside_Move,ipflexSite.Req_to_sup_IPFlex_on_AVPN_Outside_Move__c,sectionColId,premisesectionName);
                        }
                        else{
                            loadDataOnWRC(RDSExcelExportIndicesKeys.Request_to_support_IP_Flex_Reach_on_AVPN_Outside_Move,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                        }
                        if(ipflexSite.Date_of_IPFlex_on_AVPN_Outside_Move__c != null){           
                            loadDataOnWRC(RDSExcelExportIndicesKeys.Date_of_IP_Flex_Reach_on_AVPN_Outside_Move ,ipflexSite.Date_of_IPFlex_on_AVPN_Outside_Move__c.format(),sectionColId,premisesectionName);
                        }
                        else{
                            loadDataOnWRC(RDSExcelExportIndicesKeys.Date_of_IP_Flex_Reach_on_AVPN_Outside_Move ,BuyflowConstant.NA,sectionColId,premisesectionName);                        
                        }
                        if(ipflexSite.Using_BGPR__c!= null){           
                            loadDataOnWRC(RDSExcelExportIndicesKeys.BGP_R,ipflexSite.Using_BGPR__c,sectionColId,premisesectionName);
                        }
                        else{
                            loadDataOnWRC(RDSExcelExportIndicesKeys.BGP_R,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                        }
                        if(ipflexSite.Backdoor_links__c!= null){           
                            loadDataOnWRC(RDSExcelExportIndicesKeys.Backdoor_links,ipflexSite.Backdoor_links__c,sectionColId,premisesectionName);
                        }
                        else{
                            loadDataOnWRC(RDSExcelExportIndicesKeys.Backdoor_links,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                        }
                        if(ipflexSite.Call_preservation_required__c!= null){           
                            loadDataOnWRC(RDSExcelExportIndicesKeys.Call_preservation_requires_L2_backdoor_link ,ipflexSite.Call_preservation_required__c,sectionColId,premisesectionName);
                        }
                        else{
                            loadDataOnWRC(RDSExcelExportIndicesKeys.Call_preservation_requires_L2_backdoor_link ,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                        }
                        if(ipflexSite.PBX_Model_Session_Manager__c!= null){           
                            loadDataOnWRC(RDSExcelExportIndicesKeys.PBX_Model_And_Session_Manager,ipflexSite.PBX_Model_Session_Manager__c,sectionColId,premisesectionName);
                        }
                        else{
                            loadDataOnWRC(RDSExcelExportIndicesKeys.PBX_Model_And_Session_Manager,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                        }
                    }
                    //Fields only for MIS 
                    else if(product == BuyflowConstant.AMIS){
                        if(ipflexSite.Router_Shipping_First_Name__c!= null){           
                            loadDataOnWRC(BuyflowConstant.ROUTER_FIRST_NAME_CONST,ipflexSite.Router_Shipping_First_Name__c,sectionColId,premisesectionName);
                        }
                        else{
                            loadDataOnWRC(BuyflowConstant.ROUTER_FIRST_NAME_CONST,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                        }
                        if(ipflexSite.Router_Shipping_Last_Name__c!= null){           
                            loadDataOnWRC(BuyflowConstant.ROUTER_LAST_NAME_CONST,ipflexSite.Router_Shipping_Last_Name__c,sectionColId,premisesectionName);
                        }
                        else{
                            loadDataOnWRC(BuyflowConstant.ROUTER_LAST_NAME_CONST,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                        }
                        if(ipflexSite.Router_Shipping_Phone_Number__c!= null){           
                            loadDataOnWRC(BuyflowConstant.ROUTER_PHONE_NUMBER,ipflexSite.Router_Shipping_Phone_Number__c,sectionColId,premisesectionName);
                        }
                        else{
                            loadDataOnWRC(BuyflowConstant.ROUTER_PHONE_NUMBER,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                        }
                        if(ipflexSite.Router_Shipping_Address_1__c!= null){           
                            loadDataOnWRC(BuyflowConstant.ROUTER_ADDRESS_1,ipflexSite.Router_Shipping_Address_1__c,sectionColId,premisesectionName);
                        }
                        else{
                            loadDataOnWRC(BuyflowConstant.ROUTER_ADDRESS_1,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                        }
                        if(ipflexSite.Router_Shipping_Floor_Number__c!= null){           
                            loadDataOnWRC(BuyflowConstant.ROUTER_FLOOR_NUMBER,ipflexSite.Router_Shipping_Floor_Number__c,sectionColId,premisesectionName);
                        }
                        else{
                            loadDataOnWRC(BuyflowConstant.ROUTER_FLOOR_NUMBER,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                        }
                        if(ipflexSite.Router_Shipping_Room_Number__c!= null){           
                            loadDataOnWRC(BuyflowConstant.ROUTER_ROOM_NUMBER,ipflexSite.Router_Shipping_Room_Number__c,sectionColId,premisesectionName);
                        }
                        else{
                            loadDataOnWRC(BuyflowConstant.ROUTER_ROOM_NUMBER,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                        }
                        if(ipflexSite.Router_Shipping_City__c!= null){           
                            loadDataOnWRC(BuyflowConstant.ROUTER_CITY,ipflexSite.Router_Shipping_City__c,sectionColId,premisesectionName);
                        }
                        else{
                            loadDataOnWRC(BuyflowConstant.ROUTER_CITY,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                        }
                        if(ipflexSite.Router_Shipping_State__c!= null){           
                            loadDataOnWRC(BuyflowConstant.ROUTER_STATE,ipflexSite.Router_Shipping_State__c,sectionColId,premisesectionName);
                        }
                        else{
                            loadDataOnWRC(BuyflowConstant.ROUTER_STATE,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                        }
                        if(ipflexSite.Router_Shipping_Zip_Code__c!= null){           
                            loadDataOnWRC(BuyflowConstant.ROUTER_ZIP_CODE,ipflexSite.Router_Shipping_Zip_Code__c,sectionColId,premisesectionName);
                        }
                        else{
                            loadDataOnWRC(BuyflowConstant.ROUTER_ZIP_CODE,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                        }
                        if(ipflexSite.IPFlex_Reach_Traffic_Type__c!= null){           
                            loadDataOnWRC(BuyflowConstant.TYPE_OF_IPFLEX_TRAFFIC,ipflexSite.IPFlex_Reach_Traffic_Type__c,sectionColId,premisesectionName);
                        }
                        else{
                            loadDataOnWRC(BuyflowConstant.TYPE_OF_IPFLEX_TRAFFIC,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                        }
                        if(ipflexSite.Number_of_static_IP_addresses__c!= null){           
                            loadDataOnWRC(BuyflowConstant.NUMBER_OF_STATIC_IP_ADDRESSES,ipflexSite.Number_of_static_IP_addresses__c,sectionColId,premisesectionName);
                        }
                        else{
                            loadDataOnWRC(BuyflowConstant.NUMBER_OF_STATIC_IP_ADDRESSES,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                        }
                        if(domainId != null && !domainId.isWhitespace()){           
                            loadDataOnWRC(BuyflowConstant.CUSTOMER_DOMAIN_ID,BuyflowConstant.YES,sectionColId,premisesectionName);
                        }
                        else{
                            loadDataOnWRC(BuyflowConstant.CUSTOMER_DOMAIN_ID,BuyflowConstant.NO,sectionColId,premisesectionName);                        
                        }                      
                        if(domainURLfromObj!= null){           
                            loadDataOnWRC(BuyflowConstant.CUSTOMER_DOMAIN_URL,domainURLfromObj,sectionColId,premisesectionName);
                        }
                        else{
                            loadDataOnWRC(BuyflowConstant.CUSTOMER_DOMAIN_URL,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                        }
                        if(ipflexSite.PBX_Model__c!= null){
                            loadDataOnWRC(RDSExcelExportIndicesKeys.PBX_Model,ipflexSite.PBX_Model__c,sectionColId,premisesectionName);
                        }
                        else{
                            loadDataOnWRC(RDSExcelExportIndicesKeys.PBX_Model,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);
                        }
                        if(ipflexSite.PBX_or_Voice_CPE_POC_First_Name__c!= null){           
                            loadDataOnWRC(BuyflowConstant.PBX_CPE_POINT_OF_CONTACT_FIRST_NAME,ipflexSite.PBX_or_Voice_CPE_POC_First_Name__c,sectionColId,premisesectionName);
                        }
                        else{
                            loadDataOnWRC(BuyflowConstant.PBX_CPE_POINT_OF_CONTACT_FIRST_NAME,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                        }
                        if(ipflexSite.PBX_or_Voice_CPE_POC_Last_Name__c!= null){           
                            loadDataOnWRC(BuyflowConstant.PBX_CPE_POINT_OF_CONTACT_LAST_NAME,ipflexSite.PBX_or_Voice_CPE_POC_Last_Name__c,sectionColId,premisesectionName);
                        }
                        else{
                            loadDataOnWRC(BuyflowConstant.PBX_CPE_POINT_OF_CONTACT_LAST_NAME,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                        }
                        if(ipflexSite.PBX_or_Voice_CPE_POC_Phone_Number__c!= null){           
                            loadDataOnWRC(BuyflowConstant.CPE_POINT_OF_CONTACT_OFFICE_TN,ipflexSite.PBX_or_Voice_CPE_POC_Phone_Number__c,sectionColId,premisesectionName);
                        }
                        else{
                            loadDataOnWRC(BuyflowConstant.CPE_POINT_OF_CONTACT_OFFICE_TN,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                        }
                        if(ipflexSite.PBX_or_Voice_CPE_POC_Email__c!= null){           
                            loadDataOnWRC(BuyflowConstant.CPE_POINT_OF_CONTACT_EMAIL,ipflexSite.PBX_or_Voice_CPE_POC_Email__c,sectionColId,premisesectionName);
                        }
                        else{
                            loadDataOnWRC(BuyflowConstant.CPE_POINT_OF_CONTACT_EMAIL,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                        }
                        if(ipflexSite.Req_to_sup_IPFlex_on_MIS_Outside_Move__c != null){
                            loadDataOnWRC(BuyflowConstant.MOVING_EXISTING_IP_FLEX_TO_NEW_SITE_MIS,ipflexSite.Req_to_sup_IPFlex_on_MIS_Outside_Move__c,sectionColId,premisesectionName);
                        }
                         else{
                            loadDataOnWRC(BuyflowConstant.MOVING_EXISTING_IP_FLEX_TO_NEW_SITE_MIS,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                        }
                        if(ipflexSite.Date_of_IPFlex_on_MIS_Outside_Move__c!= null){
                            loadDataOnWRC(BuyflowConstant.DATE_OF_IP_FLEX_REACH_ON_MIS_OUTSIDE_MOVE,ipflexSite.Date_of_IPFlex_on_MIS_Outside_Move__c.format(),sectionColId,premisesectionName);
                        }
                         else{
                            loadDataOnWRC(BuyflowConstant.DATE_OF_IP_FLEX_REACH_ON_MIS_OUTSIDE_MOVE,BuyflowConstant.NA,sectionColId,premisesectionName);                        
                        }
                    }
                    //Fields Common for AVPN & MIS 

                    if(ipflexSite.POTS_for_testing_router__c!= null){           
                        loadDataOnWRC(BuyflowConstant.EXISTING_POTS,ipflexSite.POTS_for_testing_router__c,sectionColId,premisesectionName);
                    }
                    else{
                        loadDataOnWRC(BuyflowConstant.EXISTING_POTS,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                    }
                    if(ipflexSite.POTS_Phone_Number__c!= null){           
                        loadDataOnWRC(BuyflowConstant.SITE_POTS,ipflexSite.POTS_Phone_Number__c,sectionColId,premisesectionName);
                    }
                    else{
                        loadDataOnWRC(BuyflowConstant.SITE_POTS,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                    }
                    if(ipflexSite.IP_Flexible_Reach_Calling_Plan__c != null){           
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Type_of_IPFlex_Calling_Plan,ipflexSite.IP_Flexible_Reach_Calling_Plan__c,sectionColId,premisesectionName);
                    }
                    else{
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Type_of_IPFlex_Calling_Plan,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                    }
                    if(ipflexSite.IPFlex_Reach_Private_Dial_Plan__c != null){           
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Type_of_IPFlex_Dial_Plan,ipflexSite.IPFlex_Reach_Private_Dial_Plan__c,sectionColId,premisesectionName);
                    }
                    else{
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Type_of_IPFlex_Dial_Plan,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                    }
                    if(ipflexSite.No_of_Concurrent_Calls__c!= null){           
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Number_of_concurrent_calls,ipflexSite.No_of_Concurrent_Calls__c,sectionColId,premisesectionName);
                    }
                    else{
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Number_of_concurrent_calls,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                    }
                    if(ipflexSite.Rate_Center__c!= null){           
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Rate_Center_of_Site,ipflexSite.Rate_Center__c,sectionColId,premisesectionName);
                    }
                    else{
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Rate_Center_of_Site,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                    }
                    if(product == BuyflowConstant.AVPN){           
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Type_of_BVOIP_Service ,BuyflowConstant.NEW_AVPN_START_CONST,sectionColId,premisesectionName);
                    }
                    else if (ipflexDeal == SpecialCharacterConstant.TRUE_CAMEL_LITERAL && product == BuyflowConstant.AMIS){
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Type_of_BVOIP_Service ,BuyflowConstant.NEW_MIS_START_CONST,sectionColId,premisesectionName);                        
                    }
                    if(ipflexSite.PBX_Type__c!= null){           
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Type_of_PBX,ipflexSite.PBX_Type__c,sectionColId,premisesectionName);
                    }
                    else{
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Type_of_PBX,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                    }
                    if(ipflexSite.PBX_Interface_Type__c!= null){           
                        loadDataOnWRC(RDSExcelExportIndicesKeys.PBX_Interface_Type,ipflexSite.PBX_Interface_Type__c,sectionColId,premisesectionName);
                    }
                    else{
                        loadDataOnWRC(RDSExcelExportIndicesKeys.PBX_Interface_Type,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                    }
                    if(ipflexSite.PBX_Vendor_Mfg__c!= null){           
                        loadDataOnWRC(RDSExcelExportIndicesKeys.PBX_Vendor,ipflexSite.PBX_Vendor_Mfg__c,sectionColId,premisesectionName);
                    }
                    else{
                        loadDataOnWRC(RDSExcelExportIndicesKeys.PBX_Vendor,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                    }
                
                    if(ipflexSite.PBX_Software_Version__c!= null){           
                        loadDataOnWRC(RDSExcelExportIndicesKeys.PBX_Software_Version,ipflexSite.PBX_Software_Version__c,sectionColId,premisesectionName);
                    }
                    else{
                        loadDataOnWRC(RDSExcelExportIndicesKeys.PBX_Software_Version,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                    }
                    if(ipflexSite.CPE_Certification_Status__c!= null){           
                        loadDataOnWRC(RDSExcelExportIndicesKeys.CPE_Certification_Status,ipflexSite.CPE_Certification_Status__c,sectionColId,premisesectionName);
                    }
                    else{
                        loadDataOnWRC(RDSExcelExportIndicesKeys.CPE_Certification_Status,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                    }
                    if(ipflexSite.Inbound_Alternate_Call_Routing__c!= null){           
                        loadDataOnWRC(RDSExcelExportIndicesKeys.IAR_cannot_be_used_if_User_has_Enhanced_Features,ipflexSite.Inbound_Alternate_Call_Routing__c,sectionColId,premisesectionName);
                    }
                    else{
                        loadDataOnWRC(RDSExcelExportIndicesKeys.IAR_cannot_be_used_if_User_has_Enhanced_Features,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                    }
                    if(ipflexSite.Enhanced_Features_Services__c!= null){           
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Enhanced_Features_required,ipflexSite.Enhanced_Features_Services__c,sectionColId,premisesectionName);
                    }
                    else{
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Enhanced_Features_required,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                    }
                    if(ipflexSite.Portal_Administrator_First_Name__c!= null){           
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Enhanced_Features_Premier_Portal_Administrator_Contact_Information1,ipflexSite.Portal_Administrator_First_Name__c,sectionColId,premisesectionName);
                    }
                    else{
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Enhanced_Features_Premier_Portal_Administrator_Contact_Information1,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                    }
                    if(ipflexSite.Portal_Administrator_Last_Name__c!= null){           
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Enhanced_Features_Premier_Portal_Administrator_Contact_Information2,ipflexSite.Portal_Administrator_Last_Name__c,sectionColId,premisesectionName);
                    }
                    else{
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Enhanced_Features_Premier_Portal_Administrator_Contact_Information2,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                    }
                    if(ipflexSite.Portal_Administrator_Phone_Number__c!= null){           
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Enhanced_Features_Premier_Portal_Administrator_Contact_Information3,ipflexSite.Portal_Administrator_Phone_Number__c,sectionColId,premisesectionName);
                    }
                    else{
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Enhanced_Features_Premier_Portal_Administrator_Contact_Information3,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                    }
                    if(ipflexSite.Portal_Administrator_Email_Address__c!= null){           
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Enhanced_Features_Premier_Portal_Administrator_Contact_Information4,ipflexSite.Portal_Administrator_Email_Address__c,sectionColId,premisesectionName);
                    }
                    else{
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Enhanced_Features_Premier_Portal_Administrator_Contact_Information4,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                    }
                    if(ipflexSite.Test_Call_Phone_Number1__c!= null){           
                        loadDataOnWRC(RDSExcelExportIndicesKeys.TN_for_Enhanced_Features_Test_Call1,ipflexSite.Test_Call_Phone_Number1__c,sectionColId,premisesectionName);
                    }
                    else{
                        loadDataOnWRC(RDSExcelExportIndicesKeys.TN_for_Enhanced_Features_Test_Call1,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                    }
                    if(ipflexSite.Test_Call_Phone_Number2__c!= null){           
                        loadDataOnWRC(RDSExcelExportIndicesKeys.TN_for_Enhanced_Features_Test_Call2,ipflexSite.Test_Call_Phone_Number2__c,sectionColId,premisesectionName);
                    }
                    else{
                        loadDataOnWRC(RDSExcelExportIndicesKeys.TN_for_Enhanced_Features_Test_Call2,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                    }
                    if(ipflexSite.Call_Forwarding_required__c!= null){           
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Call_Forwarding_required,ipflexSite.Call_Forwarding_required__c,sectionColId,premisesectionName);
                    }
                    else{
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Call_Forwarding_required,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                    }
                    if(ipflexSite.Trunk_Call_Routing_Management_Required__c!= null){           
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Trunk_Call_Routing_Management_Required,ipflexSite.Trunk_Call_Routing_Management_Required__c,sectionColId,premisesectionName);
                    }
                    else{
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Trunk_Call_Routing_Management_Required,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                    }
                    if(ipflexSite.Portable_Numbers_on_Existing_IPFlex_Plan__c!= null){           
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Existing_IP_Flex_Reach_Plan_Numbers,ipflexSite.Portable_Numbers_on_Existing_IPFlex_Plan__c,sectionColId,premisesectionName);
                    }
                    else{
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Existing_IP_Flex_Reach_Plan_Numbers,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                    }
                    if(ipflexSite.Port_Type__c!= null){           
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Port_Type,ipflexSite.Port_Type__c,sectionColId,premisesectionName);
                    }
                    else{
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Port_Type,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                    }
                    if(ipflexSite.Billing_Telephone_Number__c!= null){           
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Billing_Telphone_Number,ipflexSite.Billing_Telephone_Number__c,sectionColId,premisesectionName);
                    }
                    else{
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Billing_Telphone_Number,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                    }
                    if(ipflexSite.New_Billing_Telephone_Number__c!= null){           
                        loadDataOnWRC(RDSExcelExportIndicesKeys.New_Billing_Telephone_Number,ipflexSite.New_Billing_Telephone_Number__c,sectionColId,premisesectionName);
                    }
                    else{
                        loadDataOnWRC(RDSExcelExportIndicesKeys.New_Billing_Telephone_Number,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                    }
                    if(ipflexSite.Will_the_port_include_fax_number__c!= null){           
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Will_the_port_include_fax_number,ipflexSite.Will_the_port_include_fax_number__c,sectionColId,premisesectionName);
                    }
                    else{
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Will_the_port_include_fax_number,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                    }
                    if(ipflexSite.CRS_Request_document_status__c!= null){           
                        loadDataOnWRC(RDSExcelExportIndicesKeys.CRS_Request_document_status ,ipflexSite.CRS_Request_document_status__c,sectionColId,premisesectionName);
                    }
                    else{
                        loadDataOnWRC(RDSExcelExportIndicesKeys.CRS_Request_document_status ,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                    }
                    if(ipflexSite.Number_of_Local_Phone_Numbers__c!= null){           
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Number_of_Local_Phone_Numbers,ipflexSite.Number_of_Local_Phone_Numbers__c,sectionColId,premisesectionName);
                    }
                    else{
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Number_of_Local_Phone_Numbers,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                    }
                    if(ipflexSite.Local_Phone_Number_Primary_NPA_NXX__c!= null){           
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Primary_NPA_NXX,ipflexSite.Local_Phone_Number_Primary_NPA_NXX__c,sectionColId,premisesectionName);
                    }
                    else{
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Primary_NPA_NXX,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                    }
                    if(ipflexSite.Local_Phone_Number_Secondary_NPA_NXX__c!= null){           
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Secondary_NPA_NXX,ipflexSite.Local_Phone_Number_Secondary_NPA_NXX__c,sectionColId,premisesectionName);
                    }
                    else{
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Secondary_NPA_NXX,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                    }
                    if(ipflexSite.Virtual_Phone_Number_Primary_NPA_NXX__c!= null){           
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Primary_NPA_NXX_V,ipflexSite.Virtual_Phone_Number_Primary_NPA_NXX__c,sectionColId,premisesectionName);
                    }
                    else{
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Primary_NPA_NXX_V,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                    }
                    if(ipflexSite.Virtual_Phone_Number_Secondary_NPA_NXX__c!= null){           
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Secondary_NPA_NXX_V,ipflexSite.Virtual_Phone_Number_Secondary_NPA_NXX__c,sectionColId,premisesectionName);
                    }
                    else{
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Secondary_NPA_NXX_V,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                    }
                    if(ipflexSite.Number_of_Virtual_Phone_Numbers__c!= null){           
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Number_of_Virtual_Phone_Numbers,ipflexSite.Number_of_Virtual_Phone_Numbers__c,sectionColId,premisesectionName);
                    }
                    else{
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Number_of_Virtual_Phone_Numbers,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                    }
                    if(ipflexSite.Collect_Calling_and_3rd_Party_Billing__c!= null){           
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Collect_Calling_and_3rd_Party_Billing,ipflexSite.Collect_Calling_and_3rd_Party_Billing__c,sectionColId,premisesectionName);
                    }
                    else{
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Collect_Calling_and_3rd_Party_Billing,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                    }
                    if(ipflexSite.Please_note_any_exceptions__c!= null){           
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Please_note_any_exceptions,ipflexSite.Please_note_any_exceptions__c,sectionColId,premisesectionName);
                    }
                    else{
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Please_note_any_exceptions,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                    }
                    if(ipflexSite.Calling_Name_Display__c!= null){           
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Calling_Name_CNAM_Display,ipflexSite.Calling_Name_Display__c,sectionColId,premisesectionName);
                    }
                    else{
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Calling_Name_CNAM_Display,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                    }
                    if(ipflexSite.Customer_Specified_CNAM__c!= null){           
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Customer_Specified_CNAM,ipflexSite.Customer_Specified_CNAM__c,sectionColId,premisesectionName);
                    }
                    else{
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Customer_Specified_CNAM,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                    }
                    if(ipflexSite.Directory_Listing_for_Phone_Number__c!= null){           
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Directory_Listing_Phone_Number,ipflexSite.Directory_Listing_for_Phone_Number__c,sectionColId,premisesectionName);
                    }
                    else{
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Directory_Listing_Phone_Number,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                    }
                    if(ipflexSite.Listing_Category__c!= null){           
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Listing_Category,ipflexSite.Listing_Category__c,sectionColId,premisesectionName);
                    }
                    else{
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Listing_Category,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                    }
                    if(ipflexSite.Listed_Number__c!= null){           
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Listed_Number,ipflexSite.Listed_Number__c,sectionColId,premisesectionName);
                    }
                    else{
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Listed_Number,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                    }
                    if(ipflexSite.Listed_Name__c!= null){           
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Listed_Name,ipflexSite.Listed_Name__c,sectionColId,premisesectionName);
                    }
                    else{
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Listed_Name,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                    }
                    if(ipflexSite.Dir_Listing_Dir_Assistance_for_Address__c!= null){           
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Listed_Address,ipflexSite.Dir_Listing_Dir_Assistance_for_Address__c,sectionColId,premisesectionName);
                    }
                    else{
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Listed_Address,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                    }
                    if(ipflexSite.Listing_Option__c!= null){           
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Listing_Options,ipflexSite.Listing_Option__c,sectionColId,premisesectionName);
                    }
                    else{
                        loadDataOnWRC(RDSExcelExportIndicesKeys.Listing_Options,SpecialCharacterConstant.CONCAT,sectionColId,premisesectionName);                        
                    }
                    }
                }
            }
        }
    }
}