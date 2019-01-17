public class ExportCustomerSitesController{


            String   actionType = 'ExportSites';

public WrapperUIRenderComponent wrcSites{get;set;}
WrapperUIRenderComponentBuilder      wrcbSites= null;

public ExportCustomerSitesController(){
try{
    wrcSites= new WrapperUIRenderComponent('Customer'+actionType);
    wrcbSites= new WrapperUIRenderComponentBuilder (wrcSites,'ExcelSiteList','BuyFlow','Flow',actionType);
    //callLoadExportSites(''); 
    }catch(Exception e){
    applicationException  ae= new applicationException ('00001','Exception caught while performning export of customer sites',e);
   System.debug('applicationException  caught is:'+ae);
   throw ae;
    }
}
public String sitesString{get;set;}
public WrapperUIRenderComponent callLoadExportSites(String sitesStringp){

 

   List<String> sites =sitesStringp.split(',');
   
    loadExportSites(sites);
    return wrcSites;
}
public void loadExportSites(List<String> sites){

  
List<CustomerSite__c> listOfSitesToExport = new List<CustomerSite__c>();
listOfSitesToExport = [Select Id, Site_Name__c, City__c, State__c, Address_Line__c, Zip_Code__c, Site_Description__c, BRASS_Response_Status__c, Phone__c,  VASA_Response_Status__c, Location__c, RoomBuildingFloorInput__c From CustomerSite__c Where Id in :sites];
system.debug('@@@@'+ listOfSitesToExport);
        integer i=2;

        loadExportSitesHeader(wrcbSites);
            for(CustomerSite__c obj : listOfSitesToExport ) {
                loadExportSitesData(wrcbSites,obj,i);
                i++;
            }

system.debug('wrcSites is:'+wrcSites);

}

public void loadExportSitesData(WrapperUIRenderComponentBuilder wrcbSites ,CustomerSite__c obj,integer i){
      wrcbSites.loadSectionElementAsCore('SiteName',obj.Site_Name__c,obj.id+'_SiteName',obj.id,i,1,false);           
                  wrcbSites.loadSectionElementAsCore('Address',obj.Address_Line__c,obj.id+'_'+'Address',obj.id,i,2,false);           
                  wrcbSites.loadSectionElementAsCore('Location',obj.Location__c,obj.id+'_'+'Location',obj.id,i,3,false);           
                //(obj.RoomBuildingFloorInput__c != null ?''+obj.RoomBuildingFloorInput__c:'')
                  wrcbSites.loadSectionElementAsCore('Location #',obj.RoomBuildingFloorInput__c != null ?''+obj.RoomBuildingFloorInput__c:'',obj.id+'_'+'Location #',obj.id,i,4,false);           
                  wrcbSites.loadSectionElementAsCore('City',obj.City__c,obj.id+'_'+'City',obj.id,i,5,false);           
                  wrcbSites.loadSectionElementAsCore('State',obj.State__c,obj.id+'_'+'State',obj.id,i,6,false);           
                  wrcbSites.loadSectionElementAsCore('Zip',obj.Zip_Code__c,obj.id+'_'+'Zip',obj.id,i,7,false);           
                  wrcbSites.loadSectionElementAsCore('Phone',obj.Phone__c,obj.id+'_'+'Phone',obj.id,i,8,false);           
                  wrcbSites.loadSectionElementAsCore('Status',obj.VASA_Response_Status__c,obj.id+'_'+'Status',obj.id,i,9,false);           
                
}

public void loadExportSitesHeader(WrapperUIRenderComponentBuilder wrcbSites ){
wrcbSites.loadSectionElementAsCore('SiteName','SiteName','SiteName','TeableHeader',1,1,false);           
  wrcbSites.loadSectionElementAsCore('Address','Address','Address','TeableHeader',1,2,false);           
     wrcbSites.loadSectionElementAsCore('Location','Location','Location','TeableHeader',1,3,false);           
     wrcbSites.loadSectionElementAsCore('Location #','Location #','Location #','TeableHeader',1,4,false);           
     wrcbSites.loadSectionElementAsCore('City','City','City','TeableHeader',1,5,false);           
     wrcbSites.loadSectionElementAsCore('State','State','State','TeableHeader',1,6,false);           
     wrcbSites.loadSectionElementAsCore('Zip','Zip','Zip','TeableHeader',1,7,false);           
     wrcbSites.loadSectionElementAsCore('Phone','Phone','Phone','TeableHeader',1,8,false);           
       wrcbSites.loadSectionElementAsCore('Status','Status','Status','TeableHeader',1,9,false);             
}

WrapperUIRenderComponent getSitesWRC(){
    return wrcSites;
}
}