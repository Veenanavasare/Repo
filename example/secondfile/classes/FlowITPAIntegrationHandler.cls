/************************************************************************************** 
Apex Class Name     : FlowITPAIntegrationHandler
Version             : 1.0 
Created Date        : 17 Jan 2017
Function            : Response Bean for AVPN/MIS ITPA Response
*************************************************************************************/
public class FlowITPAIntegrationHandler {
   
    /*Get Auth Token*/
    public static String getAuthCode(){
        String authCode='';
        DateTime currentTime=system.now();
        DateTime authCodeExpireTime= BlackFlageCS__c.getValues('AuthCodeRequestTime')!=null ? BlackFlageCS__c.getValues('AuthCodeRequestTime').Value__c : system.now();
    
        if(((authCodeExpireTime.getTime())/1000/60-(currentTime.getTime())/1000/60) <=0 ){
            BlackFlagIntegrationHandler handler=new BlackFlagIntegrationHandler();
            authCode=handler.InvokeBlackFlag();
        }
        else{
            authCode=Global_Variable__c.getValues('BlackFlagAccessToken').Value__c;
        }
        return authCode;
    }
    
    /*Parse ITPA Response*/
    public List<FlowITPARequestBean> parseRequestBulk(List<CustomerSite__c> custSiteList,String quoteId){
        List<FlowITPARequestBean> finalreqBeanList;
        try{
            FlowITPARequestBean reqBean;
            FlowITPARequestBean.Site reqBeanSite;
            FlowITPARequestBean.Place reqBeanPlace;
            List<FlowITPARequestBean.physicalResource> phResourceList;
           
            Integer i=0;        
            Integer noOfSitePerReq=Integer.valueof(Global_Variable__c.getValues('ITPAnoOfSitePerReq')!=null ? Global_Variable__c.getValues('ITPAnoOfSitePerReq').Value__c : '1');
            Integer noOfReq=custSiteList.size()/noOfSitePerReq;        
            Integer checkRemainingSite=(custSiteList.size()-(noOfSitePerReq*noofreq));
            Integer val=0;
            if(checkRemainingSite>val){
                noOfReq++;
            }
            
            Integer currentSite=0;
            finalreqBeanList=new List<FlowITPARequestBean>();
            for(i=0;i<noOfReq;i++){ 
                long randomno = (long) Math.floor(Math.random() * 9000000000L) + 1000000000L;
                FlowITPAResposnseBeanWrapper requestBean=new FlowITPAResposnseBeanWrapper();
                reqBean= new FlowITPARequestBean();            
                reqBean.id=quoteId+'-'+(i+1);
                Integer siteCount=0;
                system.debug('inside for and count is '+i);
                List<FlowITPARequestBean.Site> siteList = new List<FlowITPARequestBean.Site>();            
                FlowITPARequestBean finalReqBean;
                
                for(CustomerSite__c custSite: custSiteList){
              
                    reqBeanSite=new FlowITPARequestBean.Site();
                    reqBeanPlace=new FlowITPARequestBean.Place();
                    FlowITPARequestBean.Location reqBeanLocation =new FlowITPARequestBean.Location();
                    FlowITPARequestBean.LocationOptions reqBeanLocationOptions =new FlowITPARequestBean.LocationOptions();
                    FlowITPARequestBean.UnfieldedAddress reqBeanUnfieldedAddress=new FlowITPARequestBean.UnfieldedAddress();
                    
                    FlowITPARequestBean.physicalResource phyBrd=new FlowITPARequestBean.physicalResource('broadband');
                    FlowITPARequestBean.physicalResource phyCopper=new FlowITPARequestBean.physicalResource('copper');
                    FlowITPARequestBean.physicalResource phyFiber=new FlowITPARequestBean.physicalResource('fiber');
                    
                    phResourceList=new List<FlowITPARequestBean.physicalResource>();
                    phResourceList.add(phyBrd);
                    phResourceList.add(phyCopper);
                    phResourceList.add(phyFiber);
                   
                    reqBeanUnfieldedAddress.addressLine=custSiteList[currentSite].Address_Line__c;
                    reqBeanUnfieldedAddress.city=custSiteList[currentSite].City__c;
                    reqBeanUnfieldedAddress.state=custSiteList[currentSite].State__c;
                    reqBeanUnfieldedAddress.postalCode=custSiteList[currentSite].Zip_Code__c;
               
                    if(custSiteList[currentSite].Zip_Code_Extension__c!=null && custSiteList[currentSite].Zip_Code_Extension__c!=''){
                        reqBeanUnfieldedAddress.postalCodePlus4=custSiteList[currentSite].Zip_Code_Extension__c;
                    }
                    else{
                        reqBeanUnfieldedAddress.postalCodePlus4='0000';
                    }
                    reqBeanUnfieldedAddress.county='';
                     
                    reqBeanLocationOptions.unfieldedAddress=reqBeanUnfieldedAddress;
                    reqBeanLocation.locationOptions=reqBeanLocationOptions;
                    
                    reqBeanPlace.type='geographicPlace';
                    reqBeanPlace.location=reqBeanLocation;
                    
                    reqBeanSite.id=custSiteList[currentSite].id;
                    reqBeanSite.place=reqBeanPlace;
                    reqBeanSite.physicalResource=phResourceList;              
                    
                    currentSite++;
                    siteCount++;
        
                    siteList.add(reqBeanSite);
                  
                    system.debug('siteCount '+siteCount +' and noOfSitePerReq '+noOfSitePerReq );
                    system.debug('custSiteList.size() '+custSiteList.size()+' and currentSite->'+currentSite);
                    if(siteCount==noOfSitePerReq || custSiteList.size()==currentSite){
                       finalReqBean=new FlowITPARequestBean(reqBean.id,siteList);
                       finalreqBeanList.add(finalReqBean);                   
                       break;
                    }
                }
                requestBean.reqBean  = reqBean;
            }
            system.debug(finalreqBeanList.size());
            system.debug('finalreqBeanList  '+finalreqBeanList);
            
            for(FlowITPARequestBean reqBean1 : finalreqBeanList){
                system.debug(Json.serialize(reqBean1));       
            }
            system.debug('finalreqBeanList size '+finalreqBeanList.size());
      
        }
        catch(Exception e){
              system.debug('Exception '+e.getMessage()+' at line no '+e.getLineNumber());
        }
        return finalreqBeanList;
    }
}