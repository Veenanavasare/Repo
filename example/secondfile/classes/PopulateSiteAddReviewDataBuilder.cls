public class PopulateSiteAddReviewDataBuilder {
    public string actionType{get;set;}
    public Map<String,String> currDataMap {get;set;}
    public Map<String,String> propdDataMap {get;set;}
    public List<CustomerSite__c> currDataList {get;set;}
    public List<String> propdDataList {get;set;}
    public WrapperUIRenderComponentBuilder wrcb;
    
    public PopulateSiteAddReviewDataBuilder(String action){
        actionType = action;
    }
     public void executePostBuildPrep(WrapperUIRenderComponent wrc){
      wrcb.executePostBuildPrep(wrc);
       }
 

    public WrapperUIRenderComponent populateRevReqData(List<CustomerSite__c> customerSite,Map<String,boolean> junctionMap,String prod){
        
        system.debug('--action in pop builder---'+actionType);
        String actionType='Review';
        WrapperUIRenderComponent wrc= new WrapperUIRenderComponent('SiteAddressInfoTable'+actionType);
       
        wrcb= new WrapperUIRenderComponentBuilder (wrc,'ViewTable','BuyFlow','Flow',actionType);
          populateCurrentDataList(customerSite,junctionMap,prod);
      system.debug('---wrc at end of populateRevReqData---'+wrc);
        return wrc;                   
    }
    
    public void populateCurrentDataList(List<CustomerSite__c> customerSite,Map<String,boolean> junctionMap,String prod){

          integer i=1,j=1;   
       
        wrcb.loadSectionElement('Site Id','Site Id','Site Id'+i+'_'+j,'DataTableHeader',i,j) ;
        wrcb.loadSectionElement('IsSoftRemove','IsSoftRemove','IsSoftRemove'+i+'_'+j,'DataTableHeader',i,j+1) ;
        wrcb.loadSectionElement('Site Name','Site Name','Site Name'+i+'_'+j,'DataTableHeader',i,j+2) ;
        wrcb.loadSectionElement('Site Address','Site Address','Site Address'+i+'_'+j,'DataTableHeader',i,j+3) ;
        wrcb.loadSectionElement('Phone','Phone','Phone'+i+'_'+j,'DataTableHeader',i,j+4) ;
        wrcb.loadSectionElement('Site Status','Site Status','Site Status'+i+'_'+j,'DataTableHeader',i,j+5) ;
        wrcb.loadSectionElement('Action','Action','Action'+i+'_'+j,'DataTableHeader',i,j+6) ;
       
        String address='';
        String action='';
        i=2;j=1;
        system.debug('customerSite size in builder='+customerSite.size());
        for(CustomerSite__c custSite : customerSite){
      
        system.debug('value of I='+i+' and CustomerSite__c is'+custSite );
            address='';
            action='';

            wrcb.loadSectionElement( 'Site id',custSite.Id,'Site Id'+i+'_'+j,custSite.Id,i,j) ;
            //wrcb.loadSectionElement( 'IsSoftRemove',custSite.IsSoftRemove__c+'','IsSoftRemove'+i+'_'+j,custSite.Id,i,j+1) ;
            
            wrcb.loadSectionElement( 'IsSoftRemove',junctionMap.get(custSite.Id)+'','IsSoftRemove'+i+'_'+j,custSite.Id,i,j+1) ;
            wrcb.loadSectionElement( 'Site Name',custSite.Site_Name__c,'Site Name'+i+'_'+j,custSite.Id,i,j+2) ;
            wrcb.loadSectionElement( 'Site Address',custSite.Address_Line__c,'Site Address'+i+'_'+j,custSite.Id,i,j+3) ;
            wrcb.loadSectionElement( 'Site Location',custSite.Location__c,'Site Location'+i+'_'+j,custSite.Id,i,j+3) ;
            wrcb.loadSectionElement( 'Site City',custSite.City__c,'Site City'+i+'_'+j,custSite.Id,i,j+3) ;
            wrcb.loadSectionElement( 'Site State',custSite.State__c,'Site State'+i+'_'+j,custSite.Id,i,j+3) ;
            wrcb.loadSectionElement( 'Site Zip',custSite.Zip_Code__c,'Site Zip'+i+'_'+j,custSite.Id,i,j+3) ; 
          
            wrcb.loadSectionElement( 'Phone',custSite.Phone__c,'Phone'+i+'_'+j,custSite.Id,i,j+4) ;
             
            if(prod.equalsIgnoreCase(BuyflowConstant.ASE)){
                wrcb.loadSectionElement( 'SiteStatus',custSite.ASE_ITPA_Response_Status__c,'Site Status'+i+'_'+j,custSite.Id,i,j+5) ;
                //Code for action mapping
                if(custSite.ASE_ITPA_Response_Status__c  !='' && custSite.ASE_ITPA_Response_Status__c  !=null)
                {
                  if(custSite.ASE_ITPA_Response_Status__c.contains('ADDRESS NO MATCH') || custSite.ASE_ITPA_Response_Status__c.contains('ADDRESS RECORD CREATED') || custSite.ASE_ITPA_Response_Status__c.contains('POSSIBLE MATCHES') || custSite.ASE_ITPA_Response_Status__c.contains('SERVICE UNAVAILABLE'))
                 {
                  
                     wrcb.loadSectionElement( 'Edit','Edit','Edit'+i+'_'+j,custSite.Id,i,j+6) ;
                     wrcb.loadSectionElement( 'Pipe','|','Pipe'+i+'_'+j,custSite.Id,i,j+6) ;
                     wrcb.loadSectionElement( 'Remove','Remove','Remove'+i+'_'+j,custSite.Id,i,j+6) ;
                 
                 }
                else if(custSite.ASE_ITPA_Response_Status__c.contains('ADDRESS EXACT MATCH'))
                 {
                        wrcb.loadSectionElement( 'Remove','Remove','Remove'+i+'_'+j,custSite.Id,i,j+6) ;
                 }
                 
               }

            }
            else{ 
                wrcb.loadSectionElement( 'SiteStatus',custSite.VASA_Response_Status__c,'Site Status'+i+'_'+j,custSite.Id,i,j+5) ;
                //Code for action mapping
                if(custSite.VASA_Response_Status__c!='' && custSite.VASA_Response_Status__c!=null)
                {
                  if(custSite.VASA_Response_Status__c.contains('ADDRESS NO MATCH') || custSite.VASA_Response_Status__c.contains('ADDRESS RECORD CREATED') || custSite.VASA_Response_Status__c.contains('POSSIBLE MATCHES') || custSite.VASA_Response_Status__c.contains('SERVICE UNAVAILABLE'))
                 {
                  
                     wrcb.loadSectionElement( 'Edit','Edit','Edit'+i+'_'+j,custSite.Id,i,j+6) ;
                     wrcb.loadSectionElement( 'Pipe','|','Pipe'+i+'_'+j,custSite.Id,i,j+6) ;
                     wrcb.loadSectionElement( 'Remove','Remove','Remove'+i+'_'+j,custSite.Id,i,j+6) ;
                 
                 }
                else if(custSite.VASA_Response_Status__c.contains('ADDRESS EXACT MATCH'))
                 {
                        wrcb.loadSectionElement( 'Remove','Remove','Remove'+i+'_'+j,custSite.Id,i,j+6) ;
                 }
                 
               }
            }

             i++;
            
       }
           system.debug('value of i at the end='+i) ;
    }
     
    
    
}