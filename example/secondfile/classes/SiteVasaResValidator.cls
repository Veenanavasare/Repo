/****************************************************************************************************** 
Apex Class Name     : SiteVasaResValidator
Version             : 1.0 
Created Date        : 16 Oct 2014
Function            : This class handles the vasa response functionality
****************************************************************************************************/
public class SiteVasaResValidator{
    public CustomerSite__c customerSiteObj;
    public String JSONResponse;  
    public String RegEx =BuyflowConstant.QUOT_x;
    public List<String> listRes;
    public AddrValidServAvailResponseBean responseBean;
    public Map<String,String> speedElecOpticalMap {get;set;}
    public Boolean ethernetNull {get;set;}
    public Boolean privateNull {get;set;}
    public Boolean inRegion;
    
    /*************************************************************************************************************************************
    * Method name : siteVasaRes
    * Description : called from QuoteInformationController to put the logic.
    * Return Type : List<QuoteInformationController.selectPricingWrap>.
    * Parameters : String siteId,Map<String,List<SelectOption>> optGrpOptnsMap,List<Apttus_Config2__ProductClassification__c> prodOptList.
    **************************************************************************************************************************************/
    public Map<String,List<SelectOption>> siteVasaRes(String siteId,Map<String,List<SelectOption>> optGrpOptnsMap,List<Apttus_Config2__ProductClassification__c> prodOptList){
        try{
            Map<String,List<SelectOption>> optGrpOptnsMapReturn = new Map<String,List<SelectOption>>();
            Map<String,List<SelectOption>> optGrpOptnsMapTempOriginal = new Map<String,List<SelectOption>>();
            for(String tempStr : optGrpOptnsMap.keySet()){
                optGrpOptnsMapTempOriginal.put(tempStr,new List<SelectOption>(optGrpOptnsMap.get(tempStr)));
            }
            Boolean portSpeedT1 = false;
            List<SelectOption> options = new List<SelectOption>();
            Map<String,List<SelectOption>> optGrpOptionsMap = new Map<String,List<SelectOption>>();
            customerSiteObj= [select Service_Availability_Response__c,id from CustomerSite__c where id =: siteId];
            if(customerSiteObj.Service_Availability_Response__c != null){
                JSONResponse = customerSiteObj.Service_Availability_Response__c.replaceAll(RegEx,SpecialcharacterConstant.DOUBLE_QOUTE);
                responseBean = new AddrValidServAvailResponseBean();
                responseBean = (AddrValidServAvailResponseBean)JSON.deserialize(JSONResponse,AddrValidServAvailResponseBean.class);
            }
        
            if(responseBean != null && responseBean.AddressServiceAvailability != null){
                for(integer a=0;a<responseBean.AddressServiceAvailability.Size();a++){
                    for(String tempStr : optGrpOptnsMapTempOriginal.keySet()){
                        optGrpOptnsMap.put(tempStr,new List<SelectOption>(optGrpOptnsMapTempOriginal.get(tempStr)));
                    }
                    if(responseBean.AddressServiceAvailability[a].ServiceAvailabilityDetails != null){
                        if(responseBean.AddressServiceAvailability[a].ServiceAvailabilityDetails.Ethernet == null){
                            ethernetNull = true;
                            for(String optGrpTemp : optGrpOptnsMap.keyset()){
                                options = optGrpOptnsMap.get(optGrpTemp);
                                for(integer i=0;i<options.Size();i++){
                                    if(options[i].getValue().contains(BuyflowConstant.ETHERNET) && (optGrpTemp == System.Label.Product_Option_Port_Type || optGrpTemp == System.Label.Product_Option_Access_Type)){
                                        options.remove(i);
                                        i = i-1;
                                    }
                                }
                                if(optGrpTemp == System.Label.Product_Option_Port_Type && responseBean.AddressServiceAvailability[a].ServiceAvailabilityDetails.PrivateLine != null && responseBean.AddressServiceAvailability[a].ServiceAvailabilityDetails.PrivateLine.size() > 0){
                                    for(integer i=0;i<options.Size();i++){
                                        if(options[i].getValue().contains(BuyflowConstant.T3) && (responseBean.AddressServiceAvailability[a].ServiceAvailabilityDetails.PrivateLine[0].speed != null && responseBean.AddressServiceAvailability[a].ServiceAvailabilityDetails.PrivateLine[0].speed == BuyflowConstant.T1)){
                                            options.remove(i);
                                            i = i-1;
                                            portSpeedT1 = true;
                                        }
                                        else if(options[i].getValue().contains(BuyflowConstant.T1) && (responseBean.AddressServiceAvailability[a].ServiceAvailabilityDetails.PrivateLine[0].speed != null && responseBean.AddressServiceAvailability[a].ServiceAvailabilityDetails.PrivateLine[0].speed == BuyflowConstant.T3)){
                                            options.remove(i);
                                            i = i-1;
                                        }
                                    }
                                }
                            
                                if(optGrpTemp == System.Label.Product_Option_Interface_Type && responseBean.AddressServiceAvailability[a].ServiceAvailabilityDetails.PrivateLine[0].speed != null && (responseBean.AddressServiceAvailability[a].ServiceAvailabilityDetails.PrivateLine[0].speed == BuyflowConstant.T3 || responseBean.AddressServiceAvailability[a].ServiceAvailabilityDetails.PrivateLine[0].speed == BuyflowConstant.T1)){
                                    for(integer i=0;i<options.Size();i++){
                                        options[i].setDisabled(true);
                                    }
                                }
                            }
                        } 
                        else if(responseBean.AddressServiceAvailability[a].ServiceAvailabilityDetails.PrivateLine == null || responseBean.AddressServiceAvailability[a].ServiceAvailabilityDetails.PrivateLine.size() == 0){              
                            privateNull = true;
                            for(String optGrpTemp : optGrpOptnsMap.keyset()){
                                options = optGrpOptnsMap.get(optGrpTemp);
                                for(integer i=0;i<options.Size();i++){                   
                                    if(options[i].getValue().contains(BuyflowConstant.PRIVATE1) && (optGrpTemp == System.Label.Product_Option_Port_Type || optGrpTemp == System.Label.Product_Option_Access_Type)){                    
                                        options.remove(i);
                                        i = i-1;
                                    }
                                    else if(responseBean.AddressServiceAvailability[a].region == BuyflowConstant.Y && (optGrpTemp == System.Label.Product_Option_Port_Speed || optGrpTemp == System.Label.Product_Option_Access_Speed)){                        
                                       
                                    } else if ((responseBean.AddressServiceAvailability[a].region == BuyflowConstant.N || responseBean.AddressServiceAvailability[a].region == BuyflowConstant.O) && (optGrpTemp == System.Label.Product_Option_Port_Speed || optGrpTemp == System.Label.Product_Option_Access_Speed) && responseBean.AddressServiceAvailability[a].ServiceAvailabilityDetails.Ethernet.OtherSpeed != null){             
                                                   
                                    }
                                    else if(optGrpTemp == System.Label.Product_Option_Interface_Type && (responseBean.AddressServiceAvailability[a].region == BuyflowConstant.N || responseBean.AddressServiceAvailability[a].region == BuyflowConstant.O)){
                                        if(responseBean.AddressServiceAvailability[a].ServiceAvailabilityDetails.Ethernet.OtherSpeed != null && responseBean.AddressServiceAvailability[a].ServiceAvailabilityDetails.Ethernet.OtherSpeed.Size() > 0){ 
                                            speedElecOpticalMap = new Map<String,String>();
                                            for(integer j=0;j<responseBean.AddressServiceAvailability[a].ServiceAvailabilityDetails.Ethernet.OtherSpeed.Size();j++){
                                                if(responseBean.AddressServiceAvailability[a].ServiceAvailabilityDetails.Ethernet.OtherSpeed[j].speed != null){
                                                   speedElecOpticalMap.put(responseBean.AddressServiceAvailability[a].ServiceAvailabilityDetails.Ethernet.OtherSpeed[j].speed,
                                                                           responseBean.AddressServiceAvailability[a].ServiceAvailabilityDetails.Ethernet.OtherSpeed[j].electricalOptical);
                                                }
                                            } 
                                        }
                                    }
                                    else if(optGrpTemp == System.Label.Product_Option_Interface_Type && (responseBean.AddressServiceAvailability[a].region == BuyflowConstant.Y)){
                                        if(responseBean.AddressServiceAvailability[a].ServiceAvailabilityDetails.Ethernet.electricalOptical != null){ 
                                            if((responseBean.AddressServiceAvailability[a].ServiceAvailabilityDetails.Ethernet.electricalOptical == BuyflowConstant.E && options[i].getValue().contains(BuyflowConstant.OPTICAL)) || (responseBean.AddressServiceAvailability[a].ServiceAvailabilityDetails.Ethernet.electricalOptical == BuyflowConstant.O && options[i].getValue().contains(BuyflowConstant.ELECTRICAL))){ 
                                                options.remove(i);
                                                i = i-1;
                                            }
                                        }
                                    }
                                }            
                            }
                        }
                        
                        for(String tempStr : optGrpOptnsMap.keySet()){
                            List<SelectOption> newSelLst = optGrpOptnsMap.get(tempStr);                         
                            if(optGrpOptnsMapReturn.containsKey(tempStr)){
                                List<SelectOption> newSelLstReturn = optGrpOptnsMapReturn.get(tempStr);
                                newSelLstReturn.addAll(newSelLst);  
                            }
                            else{optGrpOptnsMapReturn.put(tempStr,new List<SelectOption>(optGrpOptnsMap.get(tempStr)));}
                        }
                    }
                }
            }    
            
            for(String tempStrRet : optGrpOptnsMapReturn.keySet()){
                Set<String> uniqueOpt = new Set<String>();
                List<SelectOption> uniqueSelOpt = new List<SelectOption>();
                List<SelectOption> uniqueOrderSelOpt = new List<SelectOption>();
                for(SelectOption selOptRet : optGrpOptnsMapReturn.get(tempStrRet)){
                    if(!uniqueOpt.contains(selOptRet.getValue())){
                        uniqueOrderSelOpt.add(new SelectOption(selOptRet.getValue(),selOptRet.getLabel()));
                    }
                    uniqueOpt.add(selOptRet.getValue());
                }
                optGrpOptnsMapReturn.put(tempStrRet,uniqueOrderSelOpt);
            }
            if(privateNull != null && privateNull == true && ethernetNull !=null && ethernetNull == true)
                ethernetNull = null;
            else if(privateNull != null && privateNull == true && ethernetNull == null)
                ethernetNull = true;
            else if(ethernetNull != null && ethernetNull == true && privateNull == null)
                ethernetNull = false;
            return optGrpOptnsMapReturn;        
        }catch(Exception e){
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
            return null;
        }  
    }
    
    /**********************************************************************************************
    * Method name : custSiteEligible
    * Description : called from QuoteInformationController to get the eligible sites.
    * Return Type : Map<String,Boolean>.
    * Parameters  : List<CustomerSite__c> customerSiteObjLst.
    ***********************************************************************************************/
    public Map<String,Boolean> custSiteEligible(List<CustomerSite__c> customerSiteObjLst){
        try{    
            Map<String,Boolean> custIdEthernetMap = new Map<String,Boolean>();
            AddrValidServAvailResponseBean responseBeanTemp = new AddrValidServAvailResponseBean();
            String JSONResponseStr = SpecialcharacterConstant.CONCAT;
            String maxAvailSpeed = null;
            for(CustomerSite__c tempCustSite : customerSiteObjLst){         
                Boolean privateBool = false;
                Boolean ethernetBool = false;
                
                if(tempCustSite.Service_Availability_Response__c != null){
                    JSONResponseStr = tempCustSite.Service_Availability_Response__c.replaceAll(RegEx,SpecialcharacterConstant.DOUBLE_QOUTE);
                    responseBeanTemp = (AddrValidServAvailResponseBean)JSON.deserialize(JSONResponseStr,AddrValidServAvailResponseBean.class);
                }
                if(responseBeanTemp != null && responseBeanTemp.AddressServiceAvailability != null){
                    for(integer a=0;a<responseBeanTemp.AddressServiceAvailability.Size();a++){
                        if(responseBeanTemp.AddressServiceAvailability[a].ServiceAvailabilityDetails != null){
                            if(responseBeanTemp.AddressServiceAvailability[a].ServiceAvailabilityDetails.Ethernet != null && ethernetBool == false){
                                //change made by Gaurav 1/25/2015
                                maxAvailSpeed = responseBeanTemp.AddressServiceAvailability[a].ServiceAvailabilityDetails.Ethernet.maxAvailableSpeed;
                                if(!String.isEmpty(maxAvailSpeed) && maxAvailSpeed != BuyflowConstant.SIVARConst_0){
                                    ethernetBool = true;
                                }else if(responseBeanTemp.AddressServiceAvailability[a].ServiceAvailabilityDetails.Ethernet.OtherSpeed != null && responseBeanTemp.AddressServiceAvailability[a].ServiceAvailabilityDetails.Ethernet.OtherSpeed.Size() > 0){
                                    ethernetBool = true;
                                }//End of changes                               
                            }
                            if((responseBeanTemp.AddressServiceAvailability[a].ServiceAvailabilityDetails.PrivateLine != null && responseBeanTemp.AddressServiceAvailability[a].ServiceAvailabilityDetails.PrivateLine.size() > 0) && privateBool == false){
                                for(integer b=0;b<responseBeanTemp.AddressServiceAvailability[a].ServiceAvailabilityDetails.PrivateLine.size();b++){
                                    if(responseBeanTemp.AddressServiceAvailability[a].ServiceAvailabilityDetails.PrivateLine[b].spareQuantity != null && responseBeanTemp.AddressServiceAvailability[a].ServiceAvailabilityDetails.PrivateLine[b].spareQuantity > 0){
                                        privateBool = true;
                                    }
                                }                            
                            }                       
                        }
                    }
                    if(ethernetBool == true && privateBool == false){
                        custIdEthernetMap.put(tempCustSite.Id,true);
                    }else if(ethernetBool == false && privateBool == true){
                        custIdEthernetMap.put(tempCustSite.Id,false);
                    } else{
                        custIdEthernetMap.put(tempCustSite.Id,null);
                    }
                }
            }
            return custIdEthernetMap;        
        }catch(Exception e){
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
            return null;
        }  
    }

    /******************************************************************************************************************
    * Method name : brassResValidator
    * Description : called from QuoteInformationController to read Brass response and modify the product option list.
    * Return Type : void.
    * Parameters  : String siteId,List<SelectOption> prodOptListAIAConSpeed.
    ******************************************************************************************************************/
    public List<SelectOption> brassResValidator(String siteId,List<SelectOption> prodOptListAIAConSpeed){    
        try{ 
            List<SelectOption> options = new List<SelectOption>();      
            List<SelectOption> optionsConSpeedFiltered = new List<SelectOption>();
            optionsConSpeedFiltered.add(new SelectOption(BuyflowConstant.SELECT1,BuyflowConstant.CONNECTIONSPEED));
            customerSiteObj= [select BRASSResponse__c,id from CustomerSite__c where id =: siteId];
            if(customerSiteObj.BRASSResponse__c != null){
                JSONResponse = customerSiteObj.BRASSResponse__c.replaceAll(RegEx,SpecialcharacterConstant.DOUBLE_QOUTE);
                List<BRASS_Apex2JSON_Response> brassResponse = (List<BRASS_Apex2JSON_Response>)JSON.deserialize(JSONResponse , List<BRASS_Apex2JSON_Response>.class);
                if(brassResponse != null && !brassResponse.isEmpty()){
                    List<BRASS_Apex2JSON_Response.cls_ProductQualificationResults> prodQualResultLst = new List<BRASS_Apex2JSON_Response.cls_ProductQualificationResults> ();
                    if(brassResponse[0].PreQualify_Response != null && brassResponse[0].PreQualify_Response.ProductQualificationResults != null){
                        prodQualResultLst = brassResponse[0].PreQualify_Response.ProductQualificationResults;
                    }
                    for(BRASS_Apex2JSON_Response.cls_ProductQualificationResults tempProdQualRes : prodQualResultLst){
                        if(tempProdQualRes.QualificationResultCode != null && tempProdQualRes.QualificationResultCode == BuyflowConstant.Y && tempProdQualRes.ProductName != null){
                            options.add(new SelectOption(tempProdQualRes.ProductName,tempProdQualRes.ProductName));
                        }
                    }
                    set<string> optSet = new set<string>();
                    
                    for(SelectOption sRes : options){
                        List<String> firstSplit = sRes.getValue().split(SpecialcharacterConstant.BACKSLASH2_OPEN_BRACKET);
                        List<String> secondSplit = firstSplit[1].split(SpecialcharacterConstant.BACK_SLASH2_CLOSE_BRACKET);
                        List<String> firstSplit1 = sRes.getValue().split(SpecialcharacterConstant.BACKSLASH2_OPEN_BRACKET);
                        List<String> secondSplit1 = firstSplit1[1].split(SpecialcharacterConstant.BACK_SLASH2_DOT);
                        
                        for(SelectOption sConSpeed : prodOptListAIAConSpeed){
                            if((sRes.getValue().contains(BuyflowConstant.HSIA) && sConSpeed.getLabel().contains(BuyflowConstant.BROADBAND) && sConSpeed.getLabel().contains(secondSplit[0])) || (sRes.getValue().contains(BuyflowConstant.ADSL) && sConSpeed.getLabel().contains(BuyflowConstant.ADSL) && sConSpeed.getLabel().contains(secondSplit[0])) || (sRes.getValue().contains(BuyflowConstant.SDSL) && sConSpeed.getLabel().contains(BuyflowConstant.SDSL) && sConSpeed.getLabel().contains(secondSplit[0])) || (sRes.getLabel().contains(BuyflowConstant.SIVARConst_768) && sConSpeed.getLabel().contains(BuyflowConstant.SIVARConst_768) && sConSpeed.getLabel().contains(BuyflowConstant.BROADBAND))){                           
                                if(optSet.add(sConSpeed.getLabel())){
                                    optionsConSpeedFiltered.add(new SelectOption(sConSpeed.getValue(),sConSpeed.getLabel()));
                                }
                            }                       
                        }
                        for(SelectOption sConSpeed : prodOptListAIAConSpeed){
                            if ((sRes.getValue().contains(BuyflowConstant.HSIA) && sConSpeed.getLabel().contains(BuyflowConstant.BROADBAND) && sConSpeed.getLabel().contains(secondSplit1[0])) || (sRes.getValue().contains(BuyflowConstant.ADSL) && sConSpeed.getLabel().contains(BuyflowConstant.ADSL) && sConSpeed.getLabel().contains(secondSplit1[0])) || (sRes.getValue().contains(BuyflowConstant.SDSL) && sConSpeed.getLabel().contains(BuyflowConstant.SDSL) && sConSpeed.getLabel().contains(secondSplit1[0])) || (sRes.getLabel().contains(BuyflowConstant.SIVARConst_768) && sConSpeed.getLabel().contains(BuyflowConstant.SIVARConst_768) && sConSpeed.getLabel().contains(BuyflowConstant.BROADBAND))){ 
                                if(optSet.add(sConSpeed.getLabel())){
                                    optionsConSpeedFiltered.add(new SelectOption(sConSpeed.getValue(),sConSpeed.getLabel()));
                                }
                            }
                           
                        }
                    }
                }
                if(optionsConSpeedFiltered != null && optionsConSpeedFiltered.size() > 0){
                    prodOptListAIAConSpeed = optionsConSpeedFiltered;
                }
            }
            
            return prodOptListAIAConSpeed;        
        }catch(Exception e){
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
            return null;
        }  
    }  
    
    /*******************************************************************************************************************
    * Method name : siteSARes
    * Description : called from QuoteInformationController to put the logic to filter access speed, port speed values.
    * Return Type : Set<String>.
    * Parameters : String siteId,List<QuoteProducts.Productoption> optionsList.
    ********************************************************************************************************************/
    public void siteSARes(String siteId,List<QuoteProducts.Productoption> optionsList,Set<String> sugProdId, String mainProductIdVal){
        list<selectoption> accessSpeedSelectOpt = new list<selectoption>();
        speedElecOpticalMap = new Map<String,String>();
        String maxAvailSpeed;
        String siteRegion;
        customerSiteObj= [select Service_Availability_Response__c,id from CustomerSite__c where id =: siteId];
        try{
            if(customerSiteObj.Service_Availability_Response__c != null){
                JSONResponse = customerSiteObj.Service_Availability_Response__c.replaceAll(RegEx,SpecialcharacterConstant.DOUBLE_QOUTE);
                responseBean = new AddrValidServAvailResponseBean();
                responseBean = (AddrValidServAvailResponseBean)JSON.deserialize(JSONResponse,AddrValidServAvailResponseBean.class);
            }
            if(responseBean != null && responseBean.AddressServiceAvailability != null){
                for(integer a=0;a<responseBean.AddressServiceAvailability.Size();a++){
                
                    if(responseBean.AddressServiceAvailability[a].ServiceAvailabilityDetails != null){
                        if(responseBean.AddressServiceAvailability[a].ServiceAvailabilityDetails.Ethernet == null){                            
                        } 
                        else if(responseBean.AddressServiceAvailability[a].ServiceAvailabilityDetails.PrivateLine == null || responseBean.AddressServiceAvailability[a].ServiceAvailabilityDetails.PrivateLine.size() == 0){                                  
                            siteRegion = responseBean.AddressServiceAvailability[a].region;
                            if(responseBean.AddressServiceAvailability[a].region == BuyflowConstant.Y){                        
                                maxAvailSpeed = responseBean.AddressServiceAvailability[a].ServiceAvailabilityDetails.Ethernet.maxAvailableSpeed;
                            }else if((responseBean.AddressServiceAvailability[a].region == BuyflowConstant.N || responseBean.AddressServiceAvailability[a].region == BuyflowConstant.O) && responseBean.AddressServiceAvailability[a].ServiceAvailabilityDetails.Ethernet.OtherSpeed != null && responseBean.AddressServiceAvailability[a].ServiceAvailabilityDetails.Ethernet.OtherSpeed.Size() > 0){
                                for(integer j=0;j<responseBean.AddressServiceAvailability[a].ServiceAvailabilityDetails.Ethernet.OtherSpeed.Size();j++){
                                    if(responseBean.AddressServiceAvailability[a].ServiceAvailabilityDetails.Ethernet.OtherSpeed[j].speed != null){
                                        speedElecOpticalMap.put(responseBean.AddressServiceAvailability[a].ServiceAvailabilityDetails.Ethernet.OtherSpeed[j].speed,
                                        responseBean.AddressServiceAvailability[a].ServiceAvailabilityDetails.Ethernet.OtherSpeed[j].electricalOptical);
                                    }
                                } 
                            }
                        }
                    }                    
                }
            }
            
            // start access speed, port speed filter
            for(QuoteProducts.Productoption optgrp: optionslist){
                if((optgrp.name == BuyflowConstant.ACCESSSPEED && mainProductIdVal != ProductId__c.getValues(BuyflowConstant.AMIS).Product_Id__c) || (optgrp.name == BuyflowConstant.PORTSPEED && mainProductIdVal == ProductId__c.getValues(BuyflowConstant.AMIS).Product_Id__c)){      
                    List<QuoteProducts.Productoption> tempProdOptLst = new List<QuoteProducts.Productoption>();
                    if(optgrp.name == BuyflowConstant.ACCESSSPEED){
                        tempProdOptLst = optgrp.accessSpeedList;
                    }else if(optgrp.name == BuyflowConstant.PORTSPEED){
                        tempProdOptLst = optgrp.portSpeedList;
                    }
                    for(QuoteProducts.Productoption port: tempProdOptLst){
                        if(siteRegion != null && siteRegion == BuyflowConstant.Y && !port.name.contains(BuyflowConstant.T1) && Integer.valueof((port.name.split(BuyflowConstant.MBPS2)[0]).trim()) > Integer.valueof(maxAvailSpeed)){
                            sugProdId.add(port.productid);
                        }else if(siteRegion != null && (siteRegion == BuyflowConstant.N || siteRegion == BuyflowConstant.O) && !port.name.contains(BuyflowConstant.T1) && !speedElecOpticalMap.containsKey((port.name.split(BuyflowConstant.MBPS)[0]).trim())){
                            sugProdId.add(port.productid);
                        }
                    }
                }
            }
            // end access speed, port speed filter filter
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        } 
    } 
    
    /************************************************************************************************************************************
    * Method name : siteSAResponse
    * Description : called from siteConfigureController to put the logic to filter access speed, port speed values for switched ethernet.
    * Return Type : Boolean.
    * Parameters : String siteId,List<QuoteProducts.Productoption> optionsList.
    *************************************************************************************************************************************/
    public Boolean siteSAResponse (String siteSAResponse,String siteId, String portSpeedSelectedSite,String accessSpeedSelectedSite,Boolean checkEligibility , String mainProductIdVal){
        list<selectoption> accessSpeedSelectOpt = new list<selectoption>();
        speedElecOpticalMap = new Map<String,String>();
        String maxAvailSpeed;
        String siteRegion;
        Boolean checkflag = false;
        try{
            if(siteSAResponse != null){
                JSONResponse = siteSAResponse.replaceAll(RegEx,SpecialcharacterConstant.DOUBLE_QOUTE);
                responseBean = new AddrValidServAvailResponseBean();
                responseBean = (AddrValidServAvailResponseBean)JSON.deserialize(JSONResponse,AddrValidServAvailResponseBean.class);
            }   
            if(responseBean != null && responseBean.AddressServiceAvailability != null){
                for(integer a=0;a<responseBean.AddressServiceAvailability.Size();a++){
                    if(responseBean.AddressServiceAvailability[0].ServiceAvailabilityDetails != null){
                    system.debug('*****Response****'+responseBean.AddressServiceAvailability[0].ServiceAvailabilityDetails.Ethernet);
                        if(responseBean.AddressServiceAvailability[0].ServiceAvailabilityDetails.Ethernet == null){
                            if(checkflag == false) {
                                checkEligibility = true;
                            }
                        } 
                        else if(responseBean.AddressServiceAvailability[0].ServiceAvailabilityDetails.Ethernet != null ){                                  
                            siteRegion = responseBean.AddressServiceAvailability[0].region;
                            if(responseBean.AddressServiceAvailability[0].region == BuyflowConstant.Y){                        
                               maxAvailSpeed = responseBean.AddressServiceAvailability[0].ServiceAvailabilityDetails.Ethernet.maxAvailableSpeed;
                               checkflag = true;
                               checkEligibility = false;
                               system.debug('inside SiteVasaResValidator checkEligibility false '+siteId);
                            }else if ((responseBean.AddressServiceAvailability[0].region == BuyflowConstant.N || responseBean.AddressServiceAvailability[0].region == BuyflowConstant.O) && responseBean.AddressServiceAvailability[0].ServiceAvailabilityDetails.Ethernet.OtherSpeed != null && responseBean.AddressServiceAvailability[0].ServiceAvailabilityDetails.Ethernet.OtherSpeed.Size() > 0){
                                for(integer j=0;j<responseBean.AddressServiceAvailability[0].ServiceAvailabilityDetails.Ethernet.OtherSpeed.Size();j++){
                                    if(responseBean.AddressServiceAvailability[0].ServiceAvailabilityDetails.Ethernet.OtherSpeed[j].speed != null){
                                        speedElecOpticalMap.put(responseBean.AddressServiceAvailability[0].ServiceAvailabilityDetails.Ethernet.OtherSpeed[j].speed,
                                        responseBean.AddressServiceAvailability[0].ServiceAvailabilityDetails.Ethernet.OtherSpeed[j].electricalOptical);
                                        checkflag = true;
                                        checkEligibility = false;
                                    }
                                } 
                            }
                        }
                    }           
                }
            }

            if( portSpeedSelectedSite!=null ){
                if(siteRegion != null && siteRegion == BuyflowConstant.Y && !portSpeedSelectedSite.contains(BuyflowConstant.T1) && maxAvailSpeed != null && Integer.valueof((portSpeedSelectedSite.split(BuyflowConstant.MBPS)[0]).trim()) > Integer.valueof(maxAvailSpeed)){
                    checkEligibility = true;
                }else if(siteRegion != null && (siteRegion == BuyflowConstant.N || siteRegion == BuyflowConstant.O) && !portSpeedSelectedSite.contains(BuyflowConstant.T1) && !speedElecOpticalMap.containsKey((portSpeedSelectedSite.split(BuyflowConstant.MBPS)[0]).trim())){
                    checkEligibility = true;
                }            
            }
            else{
                if(siteRegion != null && siteRegion == BuyflowConstant.Y && !accessSpeedSelectedSite.contains(BuyflowConstant.T1) && maxAvailSpeed != null && Integer.valueof((accessSpeedSelectedSite.split(BuyflowConstant.MBPS)[0]).trim()) > Integer.valueof(maxAvailSpeed)){
                    checkEligibility = true;
                }else if(siteRegion != null && (siteRegion == BuyflowConstant.N || siteRegion == BuyflowConstant.O) && !accessSpeedSelectedSite.contains(BuyflowConstant.T1) && !speedElecOpticalMap.containsKey((accessSpeedSelectedSite.split(BuyflowConstant.MBPS)[0]).trim())){
                    checkEligibility = true;
                }
            }
            // end access speed, port speed filter filter
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return checkEligibility;          
    }     
    
    public Boolean siteSAResponseNoJSON (CustomerSite__c siteObj, String portSpeedSelectedSite,String accessSpeedSelectedSite){
        list<selectoption> accessSpeedSelectOpt = new list<selectoption>();
        speedElecOpticalMap = new Map<String,String>();
        String maxAvailSpeed;
        String siteRegion;
        Boolean checkflag = false;
        Boolean checkEligibility = false;
        system.debug('checkEligibility'+checkEligibility);
        try{
            if(!siteObj.IsEtherNetAvaiable__c){
                system.debug('checkEligibility'+checkEligibility);
                if(checkflag == false){
                    system.debug('checkEligibility'+checkEligibility);
                    checkEligibility = true;
                }
            } 
            else if(siteObj.IsEtherNetAvaiable__c){         
                system.debug('checkEligibility'+checkEligibility);     
                siteRegion = siteObj.Region__c;
                if(siteRegion == BuyflowConstant.IR){              
                   system.debug('checkEligibility'+checkEligibility);          
                   maxAvailSpeed = siteObj.Ethernet_Max_Available_Speed__c;
                   checkflag = true;
                   checkEligibility = false;
                }else if (siteRegion == 'OOR' && siteObj.Ethernet_Other_Speeds__c != null){
                    system.debug('checkEligibility'+checkEligibility);
                    List<String> otherSpeedsList = siteObj.Ethernet_Other_Speeds__c.split(',');
                    for(String speed : otherSpeedsList){
                        system.debug('checkEligibility'+checkEligibility);
                        speedElecOpticalMap.put(speed,speed);
                        checkflag = true;
                        checkEligibility = false;
                    } 
                }
            }
            if(portSpeedSelectedSite!=null){
                system.debug('checkEligibility'+checkEligibility);
                if(siteRegion != null && siteRegion == BuyflowConstant.IR && !portSpeedSelectedSite.contains(BuyflowConstant.T1) && maxAvailSpeed != null && Integer.valueof((portSpeedSelectedSite.split(BuyflowConstant.MBPS)[0]).trim()) > Integer.valueof(maxAvailSpeed)){
                    system.debug('checkEligibility'+checkEligibility);
                    checkEligibility = true;
                }else if(siteRegion != null && siteRegion == 'OOR' && !portSpeedSelectedSite.contains(BuyflowConstant.T1) && !speedElecOpticalMap.containsKey((portSpeedSelectedSite.split(BuyflowConstant.MBPS)[0]).trim())){
                    system.debug('checkEligibility'+checkEligibility);
                    checkEligibility = true;
                }            
            }
            else{
                system.debug('checkEligibility'+checkEligibility);
                if(siteRegion != null && siteRegion == BuyflowConstant.IR && !accessSpeedSelectedSite.contains(BuyflowConstant.T1) && maxAvailSpeed != null && Integer.valueof((accessSpeedSelectedSite.split(BuyflowConstant.MBPS)[0]).trim()) > Integer.valueof(maxAvailSpeed)){
                    system.debug('checkEligibility'+checkEligibility);
                    checkEligibility = true;
                }else if(siteRegion != null && siteRegion == 'OOR' && !accessSpeedSelectedSite.contains(BuyflowConstant.T1) && !speedElecOpticalMap.containsKey((accessSpeedSelectedSite.split(BuyflowConstant.MBPS)[0]).trim())){
                    system.debug('checkEligibility'+checkEligibility);
                    checkEligibility = true;
                }
            }
            // end access speed, port speed filter filter
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        system.debug('checkEligibility@@@new:'+checkEligibility+' ID '+siteObj.Id);
        return checkEligibility;          
    }     
    /* 
     Name: siteSAResponseHiCapFlex
     Description: 
     */ 
     public Boolean siteSAResponseHiCapFlex(String siteSAResponseHiCapFlex,String siteId, string portSpeedSelectedSite){
        inRegion = false;
        try{
            if(siteSAResponseHiCapFlex != null){
                JSONResponse = siteSAResponseHiCapFlex.replaceAll(RegEx,SpecialcharacterConstant.DOUBLE_QOUTE);
                responseBean = new AddrValidServAvailResponseBean();
                responseBean = (AddrValidServAvailResponseBean)JSON.deserialize(JSONResponse,AddrValidServAvailResponseBean.class);
            } 
            if(responseBean != null && responseBean.AddressServiceAvailability != null){
                for(integer a=0;a<responseBean.AddressServiceAvailability.Size();a++){                                        
                      if(responseBean.AddressServiceAvailability[a].region != null && responseBean.AddressServiceAvailability[a].ServiceAvailabilityDetails != null){                             
                        if(responseBean.AddressServiceAvailability[a].ServiceAvailabilityDetails.Ethernet != null) {                                  
                            integer selPortSpeed = portSpeedSelectedSite != null ? Integer.valueof((portSpeedSelectedSite.split(BuyflowConstant.MBPS)[0]).trim()): 0;
                            integer siteMaxSpeed = responseBean.AddressServiceAvailability[a].ServiceAvailabilityDetails.Ethernet.maxAvailableSpeed != null ? Integer.valueof(responseBean.AddressServiceAvailability[a].ServiceAvailabilityDetails.Ethernet.maxAvailableSpeed) : 0;    
                            system.debug('@@@selPortSpeed: '+selPortSpeed +'@@@siteMaxSpeed: '+siteMaxSpeed);
                            if(responseBean.AddressServiceAvailability[a].region == BuyflowConstant.Y && siteMaxSpeed >= selPortSpeed){
                                inRegion = true;
                                system.debug('@@@Hi Cap Flex Eligible');
                            }
                        }   
                    }
                }   
            }        
        }
        
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return inRegion;
    }
    public Boolean siteSAResponseHiCapFlexNoJSON(CustomerSite__c siteObj, string portSpeedSelectedSite){
        inRegion = false;
        try{
            if(siteObj.Region__c != null && siteObj.IsEtherNetAvaiable__c != null){                             
                integer selPortSpeed = portSpeedSelectedSite != null ? Integer.valueof((portSpeedSelectedSite.split(BuyflowConstant.MBPS)[0]).trim()): 0;
                integer siteMaxSpeed = siteObj.Ethernet_Max_Available_Speed__c != null ? Integer.valueof(siteObj.Ethernet_Max_Available_Speed__c) : 0;    
                if(siteObj.Region__c == BuyflowConstant.IR && siteMaxSpeed >= selPortSpeed){
                    inRegion = true;
                }
            }
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        system.debug('@@@inRegion HiCap new'+inRegion+' ID '+siteObj.Id);
        return inRegion;
    }
    
    /*Method to check if speed is available for In Region site*/
    public Boolean checkSpeedAvailability(String portSpeedSelectedSite, String speedsNotAvailableCurrentSite){
        Boolean speedNotAvailableForSite = false;
        try{            
            system.debug('@@@checkSpeedAvailability - portSpeedSelectedSite: '+portSpeedSelectedSite);
            system.debug('@@@checkSpeedAvailability - speedsNotAvailableCurrentSite: '+speedsNotAvailableCurrentSite);            
            if(!String.isEmpty(portSpeedSelectedSite) && !String.isEmpty(speedsNotAvailableCurrentSite) && speedsNotAvailableCurrentSite != 'None'){
                speedsNotAvailableCurrentSite = speedsNotAvailableCurrentSite.replaceAll('M',' Mbps'); 
                speedsNotAvailableCurrentSite = speedsNotAvailableCurrentSite.replaceAll('1G','1000 Mbps');
                List<String> speedsNotAvailableList = speedsNotAvailableCurrentSite.split(',');
                for(String speed: speedsNotAvailableList){
                    if(speed == portSpeedSelectedSite){
                        system.debug('@@@Inside Speed Not Available');
                        speedNotAvailableForSite = true;
                        break;                        
                    }
                }
            }            
        }        
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return speedNotAvailableForSite;
    }
    
    /*Method to check if Site is in region*/
    public Boolean checkSiteInRegion(String serviceAvailResponse, String siteId){
        inRegion = false;
        try{
            if(serviceAvailResponse != null){
                JSONResponse = serviceAvailResponse.replaceAll(RegEx,SpecialcharacterConstant.DOUBLE_QOUTE);
                responseBean = new AddrValidServAvailResponseBean();
                responseBean = (AddrValidServAvailResponseBean)JSON.deserialize(JSONResponse, AddrValidServAvailResponseBean.class);
            } 
            if(responseBean != null && responseBean.AddressServiceAvailability != null){
                for(integer a=0 ; a<responseBean.AddressServiceAvailability.size() ; a++){                                        
                    if(responseBean.AddressServiceAvailability[a].region != null && responseBean.AddressServiceAvailability[a].ServiceAvailabilityDetails != null){                             
                        if(responseBean.AddressServiceAvailability[a].ServiceAvailabilityDetails.Ethernet != null) {
                            if(responseBean.AddressServiceAvailability[a].region == BuyflowConstant.Y){
                                inRegion = true;
                            }
                        }  
                    }
                }   
            }
        }
        
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return inRegion;
    }
    
    public Boolean checkSiteInRegionNoJSON(CustomerSite__c siteObj){
        inRegion = false;
        try{
            if(siteObj != null && String.isNotBlank(siteObj.Region__c) && siteObj.Region__c.equalsIgnoreCase('IR') && siteObj.IsEtherNetAvaiable__c){
                inRegion = true;
            }
        }catch(Exception e){
            ATTException.logException(e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        system.debug('@@@@#@#inRegion new'+inRegion+' ID '+siteObj.Id);
        return inRegion;
    }
    /* Description: US812016, method will be used to flip the vasa response */     
    public String flipVasaResponse(AddrValidServAvailResponseBean addressValidResponseBean ){
        String finalResponse='';
        try{
            system.debug('inside flipVasaResponse method of ATTServiceAvailabilityUtil class');
            AddrValidServAvailResponseBean ResponseBean = addressValidResponseBean;
         
            List<AddrValidServAvailResponseBean.AddressServiceAvailability> AddressServiceAvailabilityList = new List<AddrValidServAvailResponseBean.AddressServiceAvailability>();        
            AddressServiceAvailabilityList = ResponseBean.AddressServiceAvailability;  
            AddrValidServAvailResponseBean respBean = new AddrValidServAvailResponseBean();
            integer count = 0; 
            boolean firstEthernetFlag = true;        
            List<AddrValidServAvailResponseBean.AddressServiceAvailability> AddressServiceAvailabilityList1 = new List<AddrValidServAvailResponseBean.AddressServiceAvailability>();
            AddrValidServAvailResponseBean.ServiceAvailabilityDetails ethernet = new AddrValidServAvailResponseBean.ServiceAvailabilityDetails();
            AddrValidServAvailResponseBean.ServiceAvailabilityDetails privateLine = new AddrValidServAvailResponseBean.ServiceAvailabilityDetails();
            String ethernetRequestedSpeed = '';
            String privateLineRequestedSpeed = '';     
            
            String ethernetStatusMsg='';
            Integer ethernetStatusCode=0;
            String privateLineStatusMsg='';
            Integer privateLineStatusCode=0;
            
            integer serviceAvailCount=0;
            
            AddrValidServAvailResponseBean.ServiceAvailabilityDetails ServiceAvailabilityDetailsclassPrivateLine;
            AddrValidServAvailResponseBean.AddressServiceAvailability AddressServiceAvailabilityClassPrivateLine;
          
            AddrValidServAvailResponseBean.ServiceAvailabilityDetails ServiceAvailabilityDetailsclassEthernet ;
            AddrValidServAvailResponseBean.AddressServiceAvailability AddressServiceAvailabilityClassEthernet ;
             
            AddrValidServAvailResponseBean.AddressServiceAvailability addressServiceAvailabilityResponse ;
            AddrValidServAvailResponseBean.AddressServiceAvailability serviceAvailResponse ;
                         
            Boolean isEthernetFirst=false;
            Integer position=0;
            if(AddressServiceAvailabilityList!=null && AddressServiceAvailabilityList.size()>0){
                for (AddrValidServAvailResponseBean.AddressServiceAvailability response: AddressServiceAvailabilityList) {
                    system.debug('---response serv details---'+response.ServiceAvailabilityDetails); 
                    system.debug('---response---'+response);
                    if(response.ServiceAvailabilityDetails!=null){
                        if(response.ServiceAvailabilityDetails.Ethernet != null){                        
                            if(position ==1){
                                ServiceAvailabilityDetailsclassEthernet = new AddrValidServAvailResponseBean.ServiceAvailabilityDetails();
                                AddressServiceAvailabilityClassEthernet = new AddrValidServAvailResponseBean.AddressServiceAvailability();
                                AddressServiceAvailabilityClassEthernet = response;
                            }
                            else{
                                isEthernetFirst=true;   
                                break; 
                            }
                        }
                        else if(response.ServiceAvailabilityDetails.PrivateLine != null){
                            if(response.ServiceAvailabilityDetails.PrivateLine.size() > 0){                             
                                AddressServiceAvailabilityClassPrivateLine = new AddrValidServAvailResponseBean.AddressServiceAvailability();
                                ServiceAvailabilityDetailsclassPrivateLine = new AddrValidServAvailResponseBean.ServiceAvailabilityDetails();
                                AddressServiceAvailabilityClassPrivateLine = response;                           
                                position++;    
                            }
                        }
                        else{
                            serviceAvailResponse = new AddrValidServAvailResponseBean.AddressServiceAvailability();
                            serviceAvailResponse = response;
                            system.debug('inside else and response is '+response);                     
                            position++;    
                        }
                    }
                    else if(response.statusMessage != null && response.statusMessage.contains('Ethernet')) {
                        if(position ==1){
                            ServiceAvailabilityDetailsclassEthernet = new AddrValidServAvailResponseBean.ServiceAvailabilityDetails();
                            AddressServiceAvailabilityClassEthernet = new AddrValidServAvailResponseBean.AddressServiceAvailability();
                            AddressServiceAvailabilityClassEthernet = response;
                        }
                        else{
                            isEthernetFirst=true;   
                            break; 
                        }    
                    }else if(response.statusMessage != null && response.statusMessage.contains('PrivateLine')){
                        AddressServiceAvailabilityClassPrivateLine = new AddrValidServAvailResponseBean.AddressServiceAvailability();
                        ServiceAvailabilityDetailsclassPrivateLine = new AddrValidServAvailResponseBean.ServiceAvailabilityDetails();
                        AddressServiceAvailabilityClassPrivateLine = response;                         
                        position++;
                    }
                    else{
                        addressServiceAvailabilityResponse=new AddrValidServAvailResponseBean.AddressServiceAvailability();
                        addressServiceAvailabilityResponse = response;
                        position++;   
                    }                    
                }           
            
                if(!isEthernetFirst){
                    if(AddressServiceAvailabilityClassEthernet!=null){
                        AddressServiceAvailabilityList1.add(AddressServiceAvailabilityClassEthernet);                       
                    }
                    else if(addressServiceAvailabilityResponse!=null){
                        AddressServiceAvailabilityList1.add(addressServiceAvailabilityResponse);
                    }
                    else if(serviceAvailResponse!=null){
                        AddressServiceAvailabilityList1.add(serviceAvailResponse);
                    }
                    if(AddressServiceAvailabilityClassPrivateLine!=null){
                        AddressServiceAvailabilityList1.add(AddressServiceAvailabilityClassPrivateLine);
                    }else if(addressServiceAvailabilityResponse!=null){
                        AddressServiceAvailabilityList1.add(addressServiceAvailabilityResponse);
                    }
                    else if(serviceAvailResponse!=null){
                        AddressServiceAvailabilityList1.add(serviceAvailResponse);
                    }
                }                
            }   
            
            system.debug('AddressServiceAvailabilityList Final==' + AddressServiceAvailabilityList1);   
                
            if(!isEthernetFirst){  
                respBean.AddressServiceAvailability = new List<AddrValidServAvailResponseBean.AddressServiceAvailability>(); 
                respBean.AddressServiceAvailability.addAll(AddressServiceAvailabilityList1);                   
                finalResponse = JSON.serialize(respBean);
            }
            else{
                finalResponse = JSON.serialize(addressValidResponseBean);                
            }
            system.debug('Executed flipVasaResponse method of ATTServiceAvailabilityUtil class');        
        }
        catch(Exception e)
        {
            system.debug('---Exception at line no---'+e.getLineNumber());
            ATTException.logException( e.getTypeName(),ATTException.constructExceptionMessageString(e));
            system.debug('---Exception at line no---'+e.getLineNumber());
            return null;
        }
        return finalResponse; 
    }              
}