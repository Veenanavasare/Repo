/************************************************************************************** 
 Apex Class Name     : GetGrowPdfsCtrl 
 Version             : 1.0 
 Created Date        : 03 Oct 2016
 Function            : This class is used to get pdf details on the grow page
 Modification Log    :
* Developer                   Date                   Descriptions
* ----------------------------------------------------------------------------                 
* Eliza Viyani              10/03/2016             Original Version
**************************************************************************************/
public with sharing class GetGrowPdfsCtrl {
    
    public list<Folder> folderId; 
    public String docId;
    public Map<String,String> DocumentMap{get; set;}
    public String fileURL { get; set; } 
    public String DocURL { get; set; } 
    public Boolean PlatinumElite{ get; set; } 
    public Boolean userBeginQuote{ get; set; }
    public Boolean acctraining { get; set; }   
        
    public List<Document> DocMapGROWGuides{get; set;}    List<Integer> listGROWGuides = new List<Integer>();    Map<Integer, Document> keyMapGROWGuides = new  Map<Integer, Document>();        
    public List<Document> DocMapGROWSharedVue{get; set;}    List<Integer> listGROWSharedVue = new List<Integer>();    Map<Integer, Document> keyMapGROWSharedVue = new  Map<Integer, Document>();        
    public List<Document> DocMapGROWAdditionalBusPlan{get; set;}    List<Integer> listGROWAdditionalBusPlan = new List<Integer>();    Map<Integer, Document> keyMapGROWAdditionalBusPlan = new  Map<Integer, Document>();        
    public List<Document> DocMapSalesEnable{get; set;}    List<Integer> listSalesEnable = new List<Integer>();    Map<Integer, Document> keyMapSalesEnable = new  Map<Integer, Document>();        
    public List<Document> DocMapMRBrandGuide{get; set;}    List<Integer> listMRBrandGuide = new List<Integer>();    Map<Integer, Document> keyMapMRBrandGuide = new  Map<Integer, Document>();        
    public List<Document> DocMapMRMediaPRGuide{get; set;}    List<Integer> listMRMediaPRGuide = new List<Integer>();    Map<Integer, Document> keyMapMRMediaPRGuide = new  Map<Integer, Document>();        
    
    public List<Document> DocMapGrowMDF{get; set;}    List<Integer> listGrowMDF = new List<Integer>();    Map<Integer, Document> keyMapGrowMDF = new  Map<Integer, Document>();        
    public List<Document> DocMapGrowIDF{get; set;}    List<Integer> listGrowIDF = new List<Integer>();    Map<Integer, Document> keyMapGrowIDF = new  Map<Integer, Document>();
    public List<Document> DocMapGrowCoBranding{get; set;}    List<Integer> listGrowCoBranding = new List<Integer>();    Map<Integer, Document> keyMapGrowCoBranding = new  Map<Integer, Document>();
    public List<Document> DocMapGrowMaaS{get; set;}    List<Integer> listGrowMaaS = new List<Integer>();    Map<Integer, Document> keyMapGrowMaaS = new  Map<Integer, Document>();  
    public List<Document> DocMapGrowOrder{get; set;}    List<Integer> listGrowOrder = new List<Integer>();    Map<Integer, Document> keyMapGrowOrder = new  Map<Integer, Document>();  
    public List<Document> DocMapGrowEvent{get; set;}    List<Integer> listGrowEvent = new List<Integer>();    Map<Integer, Document> keyMapGrowEvent = new  Map<Integer, Document>();  
    public List<Document> DocMapGrowProspecting{get; set;}    List<Integer> listGrowProspecting = new List<Integer>();    Map<Integer, Document> keyMapGrowProspecting = new  Map<Integer, Document>();
    
    
    public List<Campaign> activeCampaignList{ get; set; } 
    public List<Campaign> generalList{ get; set; }     public integer generalSize{ get; set; } 
    public List<Campaign> hostingList{ get; set; }     public integer hostingSize{ get; set; }
    public List<Campaign> mobilityList{ get; set; }    public integer mobilitySize{ get; set; }
    public List<Campaign> networkList{ get; set; }     public integer networkSize{ get; set; }
    public List<Campaign> tripList{ get; set; }        public integer tripSize{ get; set; } 
    
    public GetGrowPdfsCtrl(){     
        try {    
            User us = [select Contact.account.SP_Tier__c,Begin_Quote__c,Account.Training__c from user where Id=:UserInfo.getUserId()];
            if(us!=null){ 
            if(us.Contact.account.SP_Tier__c=='Platinum Elite')
                PlatinumElite=true;
            else 
                PlatinumElite=false;
                
            userBeginQuote = us.Begin_Quote__c;
            acctraining = us.Account.Training__c;                   
            }    
            folderId = new list<Folder>();
            String pageUrl = URL.getSalesforceBaseUrl().getHost();           
            List<String> part = Apexpages.currentPage().getUrl().replace('/apex/','').split('_');  
            String part1 = part[1];
            if(part1.containsAny('?'))
            part1=part[1].substringBeforeLast('?');        
            String folderName = part[0]+'_'+part1;                      
            System.debug('***************************************************************folderName***********************************************'+folderName);            
            if(!String.isempty(folderName)){folderId = [select id from Folder where Name=:folderName Limit 1];}
            GrowSections__c sec = GrowSections__c.getvalues('sName');
            
            DocumentMap = new Map<String,String>();
            DocMapGROWGuides = new List<Document>(); 
            DocMapGROWSharedVue = new List<Document>();
            DocMapGROWAdditionalBusPlan = new List<Document>();            
            DocMapSalesEnable = new List<Document>(); 
            DocMapMRBrandGuide = new List<Document>(); 
            DocMapMRMediaPRGuide = new List<Document>(); 
            
            DocMapGrowMDF = new List<Document>(); 
            DocMapGrowIDF = new List<Document>();
            DocMapGrowCoBranding = new List<Document>();
            DocMapGrowMaaS = new List<Document>(); 
            DocMapGrowOrder = new List<Document>(); 
            DocMapGrowEvent = new List<Document>(); 
            DocMapGrowProspecting = new List<Document>();
             
                      
            if(folderId!=null && folderId.size()>0){            
                for(Document doc : [select id,URL,type,name,description,DeveloperName,keywords from Document where Document.FolderId =: folderId[0].id]){
                    DocURL = 'https://'+pageUrl+'/servlet/servlet.FileDownload?file='+doc.Id;
                    fileURL  = 'https://'+pageUrl+'/servlet/servlet.FileDownload?file='; 
             if(DocumentMap.containsKey(doc.DeveloperName)==false){
                        DocumentMap.put(doc.DeveloperName,DocURL);
                    }                      
             if(doc.keywords==sec.Grow_Guides__c){List<String> parts = doc.DeveloperName.split('_');String key = parts[parts.size()-1];if(key.isNumeric()){keyMapGROWGuides.put(Integer.ValueOf(key),doc);listGROWGuides.add(Integer.ValueOf(key));} }  //GROW_Guides                              
             if(doc.keywords==sec.Grow_SharedVue__c){List<String> parts = doc.DeveloperName.split('_');String key = parts[parts.size()-1];if(key.isNumeric()){keyMapGROWSharedVue.put(Integer.ValueOf(key),doc);listGROWSharedVue.add(Integer.ValueOf(key));} }  //GROW_SharedVue                              
             if(doc.keywords==sec.Grow_AdditionalBusPlan__c){List<String> parts = doc.DeveloperName.split('_');String key = parts[parts.size()-1];if(key.isNumeric()){keyMapGROWAdditionalBusPlan.put(Integer.ValueOf(key),doc);listGROWAdditionalBusPlan.add(Integer.ValueOf(key));} }  //GROW_AdditionalBusPlan
             if(doc.keywords==sec.Sales_Enable__c){List<String> parts = doc.DeveloperName.split('_');String key = parts[parts.size()-1];if(key.isNumeric()){keyMapSalesEnable.put(Integer.ValueOf(key),doc);listSalesEnable.add(Integer.ValueOf(key));} }  //Sales_Enable                  
             if(doc.keywords==sec.MR_BrandGuide__c){List<String> parts = doc.DeveloperName.split('_');String key = parts[parts.size()-1];if(key.isNumeric()){keyMapMRBrandGuide.put(Integer.ValueOf(key),doc);listMRBrandGuide.add(Integer.ValueOf(key));} }  //MR_BrandGuide                 
             if(doc.keywords==sec.MR_MediaPRGuide__c){List<String> parts = doc.DeveloperName.split('_');String key = parts[parts.size()-1];if(key.isNumeric()){keyMapMRMediaPRGuide.put(Integer.ValueOf(key),doc);listMRMediaPRGuide.add(Integer.ValueOf(key));} }  //MR_MediaPRGuide
             
             if(doc.keywords==sec.Grow_MDF__c){List<String> parts = doc.DeveloperName.split('_');String key = parts[parts.size()-1];if(key.isNumeric()){keyMapGrowMDF.put(Integer.ValueOf(key),doc);listGrowMDF.add(Integer.ValueOf(key));} }   
             if(doc.keywords==sec.Grow_IDF__c){List<String> parts = doc.DeveloperName.split('_');String key = parts[parts.size()-1];if(key.isNumeric()){keyMapGrowIDF.put(Integer.ValueOf(key),doc);listGrowIDF.add(Integer.ValueOf(key));} }              
             if(doc.keywords==sec.Grow_CoBranding__c){List<String> parts = doc.DeveloperName.split('_');String key = parts[parts.size()-1];if(key.isNumeric()){keyMapGrowCoBranding.put(Integer.ValueOf(key),doc);listGrowCoBranding.add(Integer.ValueOf(key));} }              
             if(doc.keywords==sec.Grow_MaaS__c){List<String> parts = doc.DeveloperName.split('_');String key = parts[parts.size()-1];if(key.isNumeric()){keyMapGrowMaaS.put(Integer.ValueOf(key),doc);listGrowMaaS.add(Integer.ValueOf(key));} }   
             if(doc.keywords==sec.Grow_Order__c){List<String> parts = doc.DeveloperName.split('_');String key = parts[parts.size()-1];if(key.isNumeric()){keyMapGrowOrder.put(Integer.ValueOf(key),doc);listGrowOrder.add(Integer.ValueOf(key));} }   
             if(doc.keywords==sec.Grow_Event__c){List<String> parts = doc.DeveloperName.split('_');String key = parts[parts.size()-1];if(key.isNumeric()){keyMapGrowEvent.put(Integer.ValueOf(key),doc);listGrowEvent.add(Integer.ValueOf(key));} }   
             if(doc.keywords==sec.Grow_Prospecting__c){List<String> parts = doc.DeveloperName.split('_');String key = parts[parts.size()-1];if(key.isNumeric()){keyMapGrowProspecting.put(Integer.ValueOf(key),doc);listGrowProspecting.add(Integer.ValueOf(key));} }   

               } // END OF FOR LOOP                          
            } // END OF IF 
            
            listGROWGuides.sort();for(Integer i :listGROWGuides) { DocMapGROWGuides.add(keyMapGROWGuides.get(i));}            
            listGROWSharedVue.sort();for(Integer i :listGROWSharedVue) { DocMapGROWSharedVue.add(keyMapGROWSharedVue.get(i));}            
            listGROWAdditionalBusPlan.sort();for(Integer i :listGROWAdditionalBusPlan) { DocMapGROWAdditionalBusPlan.add(keyMapGROWAdditionalBusPlan.get(i));}             
            listSalesEnable.sort();for(Integer i :listSalesEnable) { DocMapSalesEnable.add(keyMapSalesEnable.get(i));}                      
            listMRBrandGuide.sort();for(Integer i :listMRBrandGuide) { DocMapMRBrandGuide.add(keyMapMRBrandGuide.get(i));}                      
            listMRMediaPRGuide.sort();for(Integer i :listMRMediaPRGuide) { DocMapMRMediaPRGuide.add(keyMapMRMediaPRGuide.get(i));}                      
           
            listGROWMDF.sort();for(Integer i :listGROWMDF) { DocMapGrowMDF.add(keyMapGrowMDF.get(i));}            
            listGROWIDF.sort();for(Integer i :listGROWIDF) { DocMapGrowIDF.add(keyMapGrowIDF.get(i));} 
            listGROWCoBranding.sort();for(Integer i :listGROWCoBranding) { DocMapGrowCoBranding.add(keyMapGrowCoBranding.get(i));} 
            listGROWMaaS.sort();for(Integer i :listGROWMaaS) { DocMapGrowMaaS.add(keyMapGrowMaaS.get(i));}            
            listGROWOrder.sort();for(Integer i :listGROWOrder) { DocMapGrowOrder.add(keyMapGrowOrder.get(i));}  
            listGROWEvent.sort();for(Integer i :listGROWEvent) { DocMapGrowEvent.add(keyMapGrowEvent.get(i));}  
            listGROWProspecting.sort();for(Integer i :listGROWProspecting) { DocMapGrowProspecting.add(keyMapGrowProspecting.get(i));}  

            // END            
         
            generalSize=0;hostingSize=0;mobilitySize=0;networkSize=0;tripSize=0;
            generalList = new List<Campaign>(); hostingList= new List<Campaign>(); mobilityList= new List<Campaign>();networkList= new List<Campaign>();tripList= new List<Campaign>(); 
            activeCampaignList = [select name,type,description,(select Id from Attachments) from campaign where IsActive=true order by CreatedDate desc]; 
            if(activeCampaignList.size()>0){         
            for(Campaign c:activeCampaignList){          
            //for(Campaign c:[select name,type,description,(select Id from Attachments) from campaign where IsActive=true order by CreatedDate desc]){          
                if(c.type=='General Incentives') { if (c.Attachments.size()>0) {generalList.add(c); generalSize=1;}}
                if(c.type=='Hosting & Security Services'){ if (c.Attachments.size()>0) {hostingList.add(c); hostingSize=1;} }
                if(c.type=='Mobility Services'){ if (c.Attachments.size()>0) {mobilityList.add(c);mobilitySize=1;} }
                if(c.type=='Network Services'){ if (c.Attachments.size()>0) {networkList.add(c);networkSize=1;} }
                if(c.type=='Trip Incentive'){ if (c.Attachments.size()>0) {tripList.add(c);tripSize=1;} }                                
              }
            }
           }
            catch (Exception e) {
            String exceptionString = ATTException.constructExceptionMessageString(e);
            System.debug('Exception ---- ' + e);
            ATTException.createException(System.Label.paramMissing, e.getTypeName(), exceptionString);                        
        }
    }              
}