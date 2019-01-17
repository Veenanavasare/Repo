/************************************************************************************** 
 Apex Class Name     : GetPdfsController 
 Version             : 1.0 
 Created Date        : 29 Oct 2014
 Function            : This class is used to get pdf details of the product landing page
                       which was opened by user
 Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Karthik Gulla               10/29/2014             Original Version
**************************************************************************************/
public with sharing class GetPdfsController {
    public String Page { get; set; }
    // handle to the current instnce of the controller that can be passed to a vf component
    //public GetPdfsController thePDFControllerInstance { get { return this; } }
    public String doc { get; set; }
    public Map<String,String> DocumentMap{get; set;}
    public list<Folder> folderId; 
    
    // Added by Eliza for US615321 Mobility Pages document management on 03/29/2016   
    public String docName { get; set; }
    public String docDesc { get; set; }
    public String fileURL { get; set; } 
    public String DocURL { get; set; }    
    public String docId { get; set; }
    public boolean isWirelessProduct { get; set; }
    
    public String userName;
    public String userEmail; 
    public List<User> userAccount;
    public List<Account> accountList;
    public String uAccount;
    Datetime myDatetime = Datetime.now();
    public String dateSubmitted = myDatetime.format('MMMM dd,  yyyy');
   
    public String fileName1{ get; set;}  
    public String fileName2{ get; set;}
    public String mulFileName{ get; set;}
    
    public string esFAN{get;set;}
    public string esBName{get;set;}
    
    public String bName{get;set;}
    public String eDomain1{get;set;}
    public String eDomain2{get;set;}
    public String eDomain3{get;set;}
    public String eDomain4{get;set;}
    public String eDomain5{get;set;}
    public String eDomain6{get;set;}
    public String eDomain7{get;set;}
    public String eDomain8{get;set;}
    public String eDomain9{get;set;}
    public String eDomain10{get;set;}
    
    public string fname{get;set;}
    public string lname{get;set;}
    public string email{get;set;}
    public string address{get;set;}
    public String city{get;set;}   
    public String state{get;set;}
    public String zcode{get;set;}
    public String phno{get;set;}  
    
    public Blob mulCustUpload{get;set;}
    
    public Boolean isSAcct{get;set;}
    public Boolean isDiscount{get;set;}
    
    public String pName{get;set;}      
    public String discount{get;set;}   
    public Blob sdUpload1{get;set;}
    public String comments{get;set;} 
    
    public String desp{get;set;}    
    public Blob sdUpload2{get;set;}
    
    public String URLForProposalBuilderNav{get;set;}
    public String MarketingEdgeToken;
    public String MarketingToolKitURL;
    public Blob encryptedTokenKey;
    public String SPAccountID;
    public String CurrentTier;
    public boolean AIAConsumerEligibility; 
        
/* 
 Name: getItems
 Description: 
 */ 
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(SpecialCharacterBuyflowConstant.DOUBLEDASH,SpecialCharacterBuyflowConstant.DOUBLEDASH));
        options.add(new SelectOption(NewStartConstant.ALABAMA,NewStartConstant.AL));
        options.add(new SelectOption(NewStartConstant.ARKANSAS,NewStartConstant.AR));
        options.add(new SelectOption(NewStartConstant.ARIZONA,NewStartConstant.AZ));
        options.add(new SelectOption(NewStartConstant.CALIFORNIA,NewStartConstant.CA));
        options.add(new SelectOption(NewStartConstant.COLORADO,NewStartConstant.CO));        
        options.add(new SelectOption(NewStartConstant.CONNECTICUT,NewStartConstant.CT));
        options.add(new SelectOption(NewStartConstant.DISTRICTOF_COLUMBIA,NewStartConstant.DC));
        options.add(new SelectOption(NewStartConstant.DELAWARE,NewStartConstant.DE));
        options.add(new SelectOption(NewStartConstant.FLORIDA,NewStartConstant.FL));
        options.add(new SelectOption(NewStartConstant.GEORGIA,NewStartConstant.GA));       
        options.add(new SelectOption(NewStartConstant.IOWA,NewStartConstant.IA));        
        options.add(new SelectOption(NewStartConstant.IDAHO,NewStartConstant.ID1));
        options.add(new SelectOption(NewStartConstant.ILLINOIS,NewStartConstant.IL));
        options.add(new SelectOption('Indiana','IN'));
        options.add(new SelectOption(NewStartConstant.KANSAS,NewStartConstant.KS));
        options.add(new SelectOption(NewStartConstant.KENTUCKY,NewStartConstant.KY));        
        options.add(new SelectOption(NewStartConstant.LOUISIANA,NewStartConstant.LA));
        options.add(new SelectOption(NewStartConstant.MASSACHUSETTS,NewStartConstant.MA));
        options.add(new SelectOption(NewStartConstant.MARYLAND,NewStartConstant.MD));
        options.add(new SelectOption(NewStartConstant.MAINE,NewStartConstant.ME));
        options.add(new SelectOption(NewStartConstant.MICHIGAN,NewStartConstant.MI));
        options.add(new SelectOption(NewStartConstant.MINNESOTA,NewStartConstant.MN));   
        options.add(new SelectOption(NewStartConstant.MISSOURI,NewStartConstant.MO));     
        options.add(new SelectOption(NewStartConstant.MISSISSIPPI,NewStartConstant.MS));
        options.add(new SelectOption(NewStartConstant.MONTANA,NewStartConstant.MT)); 
        options.add(new SelectOption(NewStartConstant.NORTHCAROLINA,NewStartConstant.NC));
        options.add(new SelectOption(NewStartConstant.NORTHDAKOTA,NewStartConstant.ND));                        
        options.add(new SelectOption(NewStartConstant.NEBRASKA,NewStartConstant.NE));
        options.add(new SelectOption(NewStartConstant.NEWHAMPSHIRE,NewStartConstant.NH));        
        options.add(new SelectOption(NewStartConstant.NEWJERSEY,NewStartConstant.NJ));
        options.add(new SelectOption(NewStartConstant.NEWMEXICO,NewStartConstant.NM));
        options.add(new SelectOption(NewStartConstant.NEVADA,NewStartConstant.NV));       
        options.add(new SelectOption(NewStartConstant.NEWYORK,NewStartConstant.NY));              
        options.add(new SelectOption(NewStartConstant.OHIO,NewStartConstant.OH));
        options.add(new SelectOption(NewStartConstant.OKLAHOMA,NewStartConstant.OK));
        options.add(new SelectOption('Oregon','OR'));
        options.add(new SelectOption(NewStartConstant.PENNSYLVANIA,NewStartConstant.PA));        
        options.add(new SelectOption(NewStartConstant.RHODEISLAND,NewStartConstant.RI));
        options.add(new SelectOption(NewStartConstant.SOUTHCAROLINA,NewStartConstant.SC));
        options.add(new SelectOption(NewStartConstant.SOUTHDAKOTA,NewStartConstant.SD));
        options.add(new SelectOption(NewStartConstant.TENNESSEE,NewStartConstant.TN));
        options.add(new SelectOption(NewStartConstant.TEXAS,NewStartConstant.TX));
        options.add(new SelectOption(NewStartConstant.UTAH,NewStartConstant.UT));    
        options.add(new SelectOption(NewStartConstant.VIRGINIA,NewStartConstant.VA));    
        options.add(new SelectOption(NewStartConstant.VERMONT,NewStartConstant.VT));    
        options.add(new SelectOption(NewStartConstant.WASHINGTON,NewStartConstant.WA));
        options.add(new SelectOption(NewStartConstant.WISCONSIN,NewStartConstant.WI));
        options.add(new SelectOption(NewStartConstant.WESTVIRGINIA,NewStartConstant.WV));
        options.add(new SelectOption(NewStartConstant.WYOMING,NewStartConstant.WY));        
        return options;
    }           
    
    public List<Document> DocMapOverview{get; set;}    List<Integer> listOverview = new List<Integer>();    Map<Integer, Document> keyMapOverview = new  Map<Integer, Document>();     
    public List<Document> DocMapTraining{get; set;}    List<Integer> listTraining = new List<Integer>();    Map<Integer, Document> keyMapTraining = new  Map<Integer, Document>(); 
    public List<Document> DocMapEnablementPlaybook{get; set;}    List<Integer> listPlaybook = new List<Integer>();    Map<Integer, Document> keyMapPlaybook = new  Map<Integer, Document>();
    public List<Document> DocMapDevicePurchasing{get; set;}    List<Integer> listPurchasing = new List<Integer>();    Map<Integer, Document> keyMapPurchasing = new  Map<Integer, Document>();
    public List<Document> DocMapAccessories{get; set;}    List<Integer> listAccessories = new List<Integer>();    Map<Integer, Document> keyMapAccessories = new  Map<Integer, Document>();    
    public List<Document> DocMapDevices{get; set;}    List<Integer> listDevices = new List<Integer>();    Map<Integer, Document> keyMapDevices = new  Map<Integer, Document>();   
    public List<Document> DocMapPooling{get; set;}    List<Integer> listPooling = new List<Integer>();    Map<Integer, Document> keyMapPooling = new  Map<Integer, Document>();   
    public List<Document> DocMapBusinessConnect{get; set;}    List<Integer> listConnect = new List<Integer>();    Map<Integer, Document> keyMapConnect = new  Map<Integer, Document>();   
    public List<Document> DocMapBusinessPooled{get; set;}    List<Integer> listPooled = new List<Integer>();    Map<Integer, Document> keyMapPooled = new  Map<Integer, Document>();   
    public List<Document> DocMapSharing{get; set;}    List<Integer> listSharing = new List<Integer>();    Map<Integer, Document> keyMapSharing = new  Map<Integer, Document>();   
    public List<Document> DocMapIndividual{get; set;}    List<Integer> listIndividual = new List<Integer>();    Map<Integer, Document> keyMapIndividual = new  Map<Integer, Document>();   
    public List<Document> DocMapTalkText{get; set;}    List<Integer> listTalkText = new List<Integer>();    Map<Integer, Document> keyMapTalkText = new  Map<Integer, Document>();   
    public List<Document> DocMapTravel{get; set;}    List<Integer> listTravel = new List<Integer>();    Map<Integer, Document> keyMapTravel = new  Map<Integer, Document>();   
    public List<Document> DocMapHelpfulLinks{get; set;}    List<Integer> listHelpfulLinks = new List<Integer>();    Map<Integer, Document> keyMapHelpfulLinks = new  Map<Integer, Document>();   
    public List<Document> DocMapUseCases{get; set;}    List<Integer> listUseCases = new List<Integer>();    Map<Integer, Document> keyMapUseCases = new  Map<Integer, Document>();   
    public List<Document> DocMapSales{get; set;}      List<Integer> listSales = new List<Integer>();    Map<Integer, Document> keyMapSales = new  Map<Integer, Document>();       
    public List<Document> DocMapStartHelpful{get; set;}     List<Integer> listStartHelpful = new List<Integer>();    Map<Integer, Document> keyMapStartHelpful = new  Map<Integer, Document>();   
    public List<Document> DocMapPricing{get; set;}        List<Integer> listPricing = new List<Integer>();    Map<Integer, Document> keyMapPricing = new  Map<Integer, Document>();   
    public List<Document> DocMapEPTTLearnSales{get; set;}        List<Integer> listEPTTLearnSales = new List<Integer>();    Map<Integer, Document> keyMapEPTTLearnSales = new  Map<Integer, Document>();   
    public List<Document> DocMapEPTTLearnUseCases{get; set;}        List<Integer> listEPTTLearnUseCases = new List<Integer>();    Map<Integer, Document> keyMapEPTTLearnUseCases = new  Map<Integer, Document>();   
    public List<Document> DocMapEPTTLearnSalesFleet{get; set;}        List<Integer> listEPTTLearnSalesFleet = new List<Integer>();    Map<Integer, Document> keyMapEPTTLearnSalesFleet = new  Map<Integer, Document>();   
    public List<Document> DocMapEPTTStart{get; set;}        List<Integer> listEPTTStart = new List<Integer>();    Map<Integer, Document> keyMapEPTTStart = new  Map<Integer, Document>();   
    public List<Document> DocMapEPTTPricing{get; set;}        List<Integer> listEPTTPricing = new List<Integer>();    Map<Integer, Document> keyMapEPTTPricing = new  Map<Integer, Document>(); 
    public List<Document> DocMapFSLearnSales{get; set;}        List<Integer> listFSLearnSales = new List<Integer>();    Map<Integer, Document> keyMapFSLearnSales = new  Map<Integer, Document>();   
    public List<Document> DocMapFSLearnSalesFleet{get; set;}        List<Integer> listFSLearnSalesFleet = new List<Integer>();    Map<Integer, Document> keyMapFSLearnSalesFleet = new  Map<Integer, Document>();   
    public List<Document> DocMapFSLearnTechnical{get; set;}        List<Integer> listFSLearnTechnical = new List<Integer>();    Map<Integer, Document> keyMapFSLearnTechnical = new  Map<Integer, Document>();   
    public List<Document> DocMapFSLearnTechnicalFleet{get; set;}        List<Integer> listFSLearnTechnicalFleet = new List<Integer>();    Map<Integer, Document> keyMapFSLearnTechnicalFleet = new  Map<Integer, Document>();   
    public List<Document> DocMapFSStart{get; set;}        List<Integer> listFSStart = new List<Integer>();    Map<Integer, Document> keyMapFSStart = new  Map<Integer, Document>();   
    public List<Document> DocMapFSPricing{get; set;}        List<Integer> listFSPricing = new List<Integer>();    Map<Integer, Document> keyMapFSPricing = new  Map<Integer, Document>(); 
    public List<Document> DocMapIAPricing{get; set;}    List<Integer> listIAPricing = new List<Integer>();    Map<Integer, Document> keyMapIAPricing = new  Map<Integer, Document>();
    public List<Document> DocMapIASales{get; set;}    List<Integer> listIASales = new List<Integer>();    Map<Integer, Document> keyMapIASales = new  Map<Integer, Document>();
    public List<Document> DocMapIATechnical{get; set;}    List<Integer> listIATechnical = new List<Integer>();    Map<Integer, Document> keyMapIATechnical = new  Map<Integer, Document>();
    public List<Document> DocMapIFRPricing{get; set;}    List<Integer> listIFRPricing = new List<Integer>();    Map<Integer, Document> keyMapIFRPricing = new  Map<Integer, Document>();
    public List<Document> DocMapIFRSales{get; set;}    List<Integer> listIFRSales = new List<Integer>();    Map<Integer, Document> keyMapIFRSales = new  Map<Integer, Document>();
    public List<Document> DocMapIFRTechnical{get; set;}    List<Integer> listIFRTechnical = new List<Integer>();    Map<Integer, Document> keyMapIFRTechnical = new  Map<Integer, Document>();
    public List<Document> DocMapDevDocumentation{get; set;}        List<Integer> listDevDocumentation = new List<Integer>();    Map<Integer, Document> keyMapDevDocumentation = new  Map<Integer, Document>();   
    public List<Document> DocMapANIRAPricing{get; set;}    List<Integer> listANIRAPricing = new List<Integer>();    Map<Integer, Document> keyMapANIRAPricing = new  Map<Integer, Document>();
    public List<Document> DocMapANIRASales{get; set;}    List<Integer> listANIRASales = new List<Integer>();    Map<Integer, Document> keyMapANIRASales = new  Map<Integer, Document>();
    public List<Document> DocMapANIRATechnical{get; set;}    List<Integer> listANIRATechnical = new List<Integer>();    Map<Integer, Document> keyMapANIRATechnical = new  Map<Integer, Document>();
    public List<Document> DocMapNBFWPricing{get; set;}    List<Integer> listNBFWPricing = new List<Integer>();    Map<Integer, Document> keyMapNBFWPricing = new  Map<Integer, Document>();
    public List<Document> DocMapNBFWSales{get; set;}    List<Integer> listNBFWSales = new List<Integer>();    Map<Integer, Document> keyMapNBFWSales = new  Map<Integer, Document>();
    public List<Document> DocMapNBFWTechnical{get; set;}    List<Integer> listNBFWTechnical = new List<Integer>();    Map<Integer, Document> keyMapNBFWTechnical = new  Map<Integer, Document>();
    public List<Document> DocMapCampaignResources{get; set;}    List<Integer> listCampaignResources = new List<Integer>();    Map<Integer, Document> keyMapCampaignResources = new  Map<Integer, Document>();
    public List<Document> DocMapCampaignNetworkService{get; set;}    List<Integer> listCampaignNetworkService = new List<Integer>();    Map<Integer, Document> keyMapCampaignNetworkService = new  Map<Integer, Document>();
    public List<Document> DocMapCampaignMobileService{get; set;}    List<Integer> listCampaignMobileService = new List<Integer>();    Map<Integer, Document> keyMapCampaignMobileService = new  Map<Integer, Document>();
    public List<Document> DocMapCampaignHostingService{get; set;}    List<Integer> listCampaignHostingService = new List<Integer>();    Map<Integer, Document> keyMapCampaignHostingService = new  Map<Integer, Document>();
    public List<Document> DocMapCampaignBiFold{get; set;}    List<Integer> listCampaignBiFold = new List<Integer>();    Map<Integer, Document> keyMapCampaignBiFold = new  Map<Integer, Document>();    
    public List<Document> DocMapProposalResources{get; set;}    List<Integer> listProposalResources = new List<Integer>();    Map<Integer, Document> keyMapProposalResources = new  Map<Integer, Document>();
    public Map<String, String> keyMapURL{get; set;}        Map<String, String> keyMapAssignment = new  Map<String, String>();        List<String> listAssignment = new List<String>(); 
    public Map<String, String> keyMapMobileURL{get; set;}  Map<String, String> keyMapMobileAssignment = new  Map<String, String>();  List<String> listMobileAssignment = new List<String>(); 
    public Map<String, String> keyMapHostingURL{get; set;} Map<String, String> keyMapHostingAssignment = new  Map<String, String>(); List<String> listHostingAssignment = new List<String>(); 
    public Map<String, String> keyMapBiFoldURL{get; set;}  Map<String, String> keyMapBiFoldAssignment = new  Map<String, String>();  List<String> listBiFoldAssignment = new List<String>();    
    public List<Document> DocMapAVPNSalesReources{get; set;}    List<Integer> listAVPNSalesReources = new List<Integer>();    Map<Integer, Document> keyMapAVPNSalesReources = new  Map<Integer, Document>();
    public List<Document> DocMapAVPNTechnicalInfo{get; set;}    List<Integer> listAVPNTechnicalInfo = new List<Integer>();    Map<Integer, Document> keyMapAVPNTechnicalInfo = new  Map<Integer, Document>();
    public List<Document> DocMapAVPNGetStarted{get; set;}    List<Integer> listAVPNGetStarted = new List<Integer>();    Map<Integer, Document> keyMapAVPNGetStarted = new  Map<Integer, Document>();
    public List<Document> DocMapAVPNPricing{get; set;}    List<Integer> listAVPNPricing = new List<Integer>();    Map<Integer, Document> keyMapAVPNPricing = new  Map<Integer, Document>();    
    public List<Document> DocMapMISSales{get; set;}    List<Integer> listMISSales = new List<Integer>();    Map<Integer, Document> keyMapMISSales = new  Map<Integer, Document>();
    public List<Document> DocMapMISTechnical{get; set;}    List<Integer> listMISTechnical = new List<Integer>();    Map<Integer, Document> keyMapMISTechnical = new  Map<Integer, Document>();
    public List<Document> DocMapMISGet{get; set;}    List<Integer> listMISGet = new List<Integer>();    Map<Integer, Document> keyMapMISGet = new  Map<Integer, Document>();    
    public List<Document> DocMapMISPricing{get; set;}    List<Integer> listMISPricing = new List<Integer>();    Map<Integer, Document> keyMapMISPricing = new  Map<Integer, Document>();        
    public List<Document> DocMapASESales{get; set;}    List<Integer> listASESales = new List<Integer>();    Map<Integer, Document> keyMapASESales = new  Map<Integer, Document>();
    public List<Document> DocMapASETechnical{get; set;}    List<Integer> listASETechnical = new List<Integer>();    Map<Integer, Document> keyMapASETechnical = new  Map<Integer, Document>();
    public List<Document> DocMapASEGet{get; set;}    List<Integer> listASEGet = new List<Integer>();    Map<Integer, Document> keyMapASEGet = new  Map<Integer, Document>();    
    public List<Document> DocMapASEPricing{get; set;}    List<Integer> listASEPricing = new List<Integer>();    Map<Integer, Document> keyMapASEPricing = new  Map<Integer, Document>();        
    public List<Document> DocMapSEGSales{get; set;}    List<Integer> listSEGSales = new List<Integer>();    Map<Integer, Document> keyMapSEGSales = new  Map<Integer, Document>();
    public List<Document> DocMapSEGTechnical{get; set;}    List<Integer> listSEGTechnical = new List<Integer>();    Map<Integer, Document> keyMapSEGTechnical = new  Map<Integer, Document>();
    public List<Document> DocMapSEGGet{get; set;}    List<Integer> listSEGGet = new List<Integer>();    Map<Integer, Document> keyMapSEGGet = new  Map<Integer, Document>();    
    public List<Document> DocMapSEGPricing{get; set;}    List<Integer> listSEGPricing = new List<Integer>();    Map<Integer, Document> keyMapSEGPricing = new  Map<Integer, Document>();
    public List<Document> DocMapWWANView1{get; set;}    List<Integer> listWWANView1 = new List<Integer>();    Map<Integer, Document> keyMapWWANView1 = new  Map<Integer, Document>();    
    public List<Document> DocMapWWANView2{get; set;}    List<Integer> listWWANView2 = new List<Integer>();    Map<Integer, Document> keyMapWWANView2 = new  Map<Integer, Document>();    
    public List<Document> DocMapWWANView3{get; set;}    List<Integer> listWWANView3 = new List<Integer>();    Map<Integer, Document> keyMapWWANView3 = new  Map<Integer, Document>();    
    public List<Document> DocMapWWANView4{get; set;}    List<Integer> listWWANView4 = new List<Integer>();    Map<Integer, Document> keyMapWWANView4 = new  Map<Integer, Document>();    
    public List<Document> DocMapWWANView5{get; set;}    List<Integer> listWWANView5 = new List<Integer>();    Map<Integer, Document> keyMapWWANView5 = new  Map<Integer, Document>();    
    public List<Document> DocMapWWANSales{get; set;}    List<Integer> listWWANSales = new List<Integer>();    Map<Integer, Document> keyMapWWANSales = new  Map<Integer, Document>();
    public List<Document> DocMapWWANSalesBusiness{get; set;}    List<Integer> listWWANSalesBusiness = new List<Integer>();    Map<Integer, Document> keyMapWWANSalesBusiness = new  Map<Integer, Document>();
    public List<Document> DocMapWWANSalesAccess{get; set;}    List<Integer> listWWANSalesAccess = new List<Integer>();    Map<Integer, Document> keyMapWWANSalesAccess = new  Map<Integer, Document>();
    public List<Document> DocMapWWANSalesCommercial{get; set;}    List<Integer> listWWANSalesCommercial = new List<Integer>();    Map<Integer, Document> keyMapWWANSalesCommercial= new  Map<Integer, Document>();
    public List<Document> DocMapWWANTechnicalBusiness{get; set;}    List<Integer> listWWANTechnicalBusiness = new List<Integer>();    Map<Integer, Document> keyMapWWANTechnicalBusiness = new  Map<Integer, Document>();
    public List<Document> DocMapWWANTechnicalAccess{get; set;}    List<Integer> listWWANTechnicalAccess = new List<Integer>();    Map<Integer, Document> keyMapWWANTechnicalAccess = new  Map<Integer, Document>();
    public List<Document> DocMapWWANTechnicalCommercial{get; set;}    List<Integer> listWWANTechnicalCommercial = new List<Integer>();    Map<Integer, Document> keyMapWWANTechnicalCommercial = new  Map<Integer, Document>();
    public List<Document> DocMapWWANGet{get; set;}    List<Integer> listWWANGet = new List<Integer>();    Map<Integer, Document> keyMapWWANGet = new  Map<Integer, Document>();    
    public List<Document> DocMapWWANPricing{get; set;}    List<Integer> listWWANPricing = new List<Integer>();    Map<Integer, Document> keyMapWWANPricing = new  Map<Integer, Document>();        
    public List<Document> DocMapGROWGuides{get; set;}    List<Integer> listGROWGuides = new List<Integer>();    Map<Integer, Document> keyMapGROWGuides = new  Map<Integer, Document>();        
    public List<Document> DocMapCWSSales{get; set;}    List<Integer> listCWSSales = new List<Integer>();    Map<Integer, Document> keyMapCWSSales = new  Map<Integer, Document>();
    public List<Document> DocMapCWSTechnical{get; set;}    List<Integer> listCWSTechnical = new List<Integer>();    Map<Integer, Document> keyMapCWSTechnical = new  Map<Integer, Document>();
    public List<Document> DocMapCWSGet{get; set;}    List<Integer> listCWSGet = new List<Integer>();    Map<Integer, Document> keyMapCWSGet = new  Map<Integer, Document>();    
    public List<Document> DocMapCWSPricing{get; set;}    List<Integer> listCWSPricing = new List<Integer>();    Map<Integer, Document> keyMapCWSPricing = new  Map<Integer, Document>();        
    public List<Document> DocMapNetBSales{get; set;}    List<Integer> listNetBSales = new List<Integer>();    Map<Integer, Document> keyMapNetBSales = new  Map<Integer, Document>();
    public List<Document> DocMapNetBGet{get; set;}    List<Integer> listNetBGet = new List<Integer>();    Map<Integer, Document> keyMapNetBGet = new  Map<Integer, Document>();    
    public List<Document> DocMapNetBPricing{get; set;}    List<Integer> listNetBPricing = new List<Integer>();    Map<Integer, Document> keyMapNetBPricing = new  Map<Integer, Document>();        
    public List<Document> DocMapCOLOSales{get; set;}    List<Integer> listCOLOSales = new List<Integer>();    Map<Integer, Document> keyMapCOLOSales = new  Map<Integer, Document>();
    public List<Document> DocMapCOLOTechnical{get; set;}    List<Integer> listCOLOTechnical = new List<Integer>();    Map<Integer, Document> keyMapCOLOTechnical = new  Map<Integer, Document>();
    public List<Document> DocMapCOLOGet{get; set;}    List<Integer> listCOLOGet = new List<Integer>();    Map<Integer, Document> keyMapCOLOGet = new  Map<Integer, Document>();    
    public List<Document> DocMapCOLOPricing{get; set;}    List<Integer> listCOLOPricing = new List<Integer>();    Map<Integer, Document> keyMapCOLOPricing = new  Map<Integer, Document>();        
    public List<Document> DocMapSalesEnable{get; set;}    List<Integer> listSalesEnable = new List<Integer>();    Map<Integer, Document> keyMapSalesEnable = new  Map<Integer, Document>();  
    public List<Document> DocMapIOTCCSales{get; set;}    List<Integer> listIOTCCSales = new List<Integer>();    Map<Integer, Document> keyMapIOTCCSales = new  Map<Integer, Document>();       
    public List<Document> DocMapIOTCCTech{get; set;}    List<Integer> listIOTCCTech = new List<Integer>();    Map<Integer, Document> keyMapIOTCCTech = new  Map<Integer, Document>(); 
    public List<Document> DocMapIOTCVSales{get; set;}    List<Integer> listIOTCVSales = new List<Integer>();    Map<Integer, Document> keyMapIOTCVSales = new  Map<Integer, Document>();        
    public List<Document> DocMapIOTCVTech{get; set;}    List<Integer> listIOTCVTech = new List<Integer>();    Map<Integer, Document> keyMapIOTCVTech = new  Map<Integer, Document>(); 
    public List<Document> DocMapIOTSCPSale{get; set;}    List<Integer> listIOTSCPSale = new List<Integer>();    Map<Integer, Document> keyMapIOTSCPSale = new  Map<Integer, Document>();        
    public List<Document> DocMapIOTSCRetail{get; set;}    List<Integer> listIOTSCRetail = new List<Integer>();    Map<Integer, Document> keyMapIOTSCRetail = new  Map<Integer, Document>(); 
    public List<Document> DocMapIOTSCRetail2{get; set;}    List<Integer> listIOTSCRetail2 = new List<Integer>();    Map<Integer, Document> keyMapIOTSCRetail2 = new  Map<Integer, Document>(); 
    public List<Document> DocMapIOTSCContainer{get; set;}    List<Integer> listIOTSCContainer = new List<Integer>();    Map<Integer, Document> keyMapIOTSCContainer = new  Map<Integer, Document>(); 
    public List<Document> DocMapIOTAssess{get; set;}        List<Integer> listIOTAssess = new List<Integer>();    Map<Integer, Document> keyMapIOTAssess = new  Map<Integer, Document>();   
    public List<Document> DocMapIOTStart{get; set;}        List<Integer> listIOTStart = new List<Integer>();    Map<Integer, Document> keyMapIOTStart = new  Map<Integer, Document>();   
    public List<Document> DocMapIOTPricing{get; set;}        List<Integer> listIOTPricing = new List<Integer>();    Map<Integer, Document> keyMapIOTPricing = new  Map<Integer, Document>();    
    public List<Document> DocMapFlexWareSales{get; set;}        List<Integer> listFlexWareSales = new List<Integer>();    Map<Integer, Document> keyMapFlexWareSales = new  Map<Integer, Document>(); 
    public List<Document> DocMapFlexWareTechnical{get; set;}    List<Integer> listFlexWareTechnical = new List<Integer>();    Map<Integer, Document> keyMapFlexWareTechnical = new  Map<Integer, Document>();  
    public List<Document> DocMapFlexWareGet{get; set;}        List<Integer> listFlexWareGet = new List<Integer>();    Map<Integer, Document> keyMapFlexWareGet = new  Map<Integer, Document>();  
    public List<Document> DocMapFlexWarePricing{get; set;}        List<Integer> listFlexWarePricing = new List<Integer>();    Map<Integer, Document> keyMapFlexWarePricing = new  Map<Integer, Document>();  
    public List<Document> DocMapDESales{get; set;}        List<Integer> listDESales = new List<Integer>();    Map<Integer, Document> keyMapDESales = new  Map<Integer, Document>(); 
    public List<Document> DocMapDETechnical{get; set;}    List<Integer> listDETechnical = new List<Integer>();    Map<Integer, Document> keyMapDETechnical = new  Map<Integer, Document>();  
    public List<Document> DocMapDEGet{get; set;}        List<Integer> listDEGet = new List<Integer>();    Map<Integer, Document> keyMapDEGet = new  Map<Integer, Document>();  
    // End               
/* 
 Name: GetPdfsController
 Description: 
 */ 
    public GetPdfsController(){     
        try {
          AIAConsumerEligibility = false;
             // Added by Eliza for US615321 Mobility Pages document management on 03/29/2016
            userName = UserInfo.getFirstName() +' '+  UserInfo.getLastName();
            userEmail= UserInfo.getUserEmail(); 
            UserAccount = [select Account_Name__c,Account.id from user where id=:UserInfo.getUserId()];             
            accountList = [select SFDC_SP_Account_ID__c,Current_Tier__c,name,Mobility_L2_ID__c,AgreementID__c,Billing_Address__c,Billing_State__c,Billing_Zip_Code__c,
                                  Billing_City__c,AIA_Consumer_Eligibility__c,Wireless_Product__c from Account where Id =: userAccount[0].Account.id];
            if(!Test.isRunningTest()){
            isWirelessProduct = (accountList[0].Wireless_Product__c) ? true : false;
            }
            if (accountList.size()>0)uAccount = accountList[0].name;                     
            if(accountList.isempty()){
                SPAccountID = SpecialCharacterBuyflowConstant.CONCAT;
                CurrentTier = SpecialCharacterBuyflowConstant.CONCAT;           
            }else{ 
                SPAccountID = accountList[0].SFDC_SP_Account_ID__c;
                CurrentTier = accountList[0].Current_Tier__c;
                AIAConsumerEligibility = accountList[0].AIA_Consumer_Eligibility__c;
            }

            MarketingEdgeToken = Global_Variable__c.getValues('MARKETING_EDGE_TOKEN') != null ? Global_Variable__c.getValues('MARKETING_EDGE_TOKEN').Value__c : '';
            MarketingToolKitURL = Global_Variable__c.getValues('MARKETING_TOOLKIT_URL') != null ? Global_Variable__c.getValues('MARKETING_TOOLKIT_URL').Value__c : '';
            encryptedTokenKey = EncodingUtil.base64Decode(MarketingEdgeToken);
            
            folderId = new list<Folder>();
            String pageUrl = URL.getSalesforceBaseUrl().getHost();           
            List<String> part = Apexpages.currentPage().getUrl().replace('/apex/','').split('_');  
            String part1 = part[1];
            if(part1.containsAny('?'))
            part1=part[1].substringBeforeLast('?');        
            String folderName = part[0]+'_'+part1;
                                 
            if(!String.isempty(folderName)){
            
                if(folderName == NewStartConstant.PORTALDESIGNDEVELOPERS){
                    folderName = 'API Developer Documentation – Current';
                }
            
            }
            if(!String.isempty(folderName)){folderId = [select id from Folder where Name=:folderName Limit 1];}
            MobilitySection__c sec = MobilitySection__c.getvalues('sName');
            DocumentMap = new Map<String,String>();
            DocMapOverview = new List<Document>();
            DocMapTraining = new List<Document>();
            DocMapEnablementPlaybook= new List<Document>();
            DocMapDevicePurchasing= new List<Document>();
            DocMapAccessories= new List<Document>();
            DocMapDevices= new List<Document>();    
            DocMapPooling= new List<Document>();
            DocMapBusinessConnect= new List<Document>();
            DocMapBusinessPooled= new List<Document>();
            DocMapSharing= new List<Document>();
            DocMapIndividual= new List<Document>();   
            DocMapTalkText= new List<Document>();
            DocMapTravel= new List<Document>();
            DocMapHelpfulLinks= new List<Document>();
            DocMapUseCases= new List<Document>();
            DocMapSales= new List<Document>();
            DocMapStartHelpful= new List<Document>();
            DocMapPricing= new List<Document>();  
            DocMapEPTTLearnSales= new List<Document>();
            DocMapEPTTLearnUseCases= new List<Document>();            
            DocMapEPTTLearnSalesFleet= new List<Document>();            
            DocMapEPTTStart= new List<Document>();
            DocMapEPTTPricing= new List<Document>();
            DocMapFSLearnSales= new List<Document>();
            DocMapFSLearnSalesFleet= new List<Document>();  
            DocMapFSLearnTechnical= new List<Document>();            
            DocMapFSLearnTechnicalFleet= new List<Document>();            
            DocMapFSStart= new List<Document>();
            DocMapFSPricing= new List<Document>();            
            DocMapIAPricing= new List<Document>();     
            DocMapIASales= new List<Document>();
            DocMapIATechnical= new List<Document>(); 
            DocMapIFRPricing= new List<Document>();     
            DocMapIFRSales= new List<Document>();
            DocMapIFRTechnical= new List<Document>(); 
            DocMapANIRAPricing= new List<Document>();                
            DocMapANIRASales= new List<Document>();                
            DocMapANIRATechnical= new List<Document>();  
            DocMapNBFWPricing= new List<Document>();                
            DocMapNBFWSales= new List<Document>();                
            DocMapNBFWTechnical= new List<Document>();            
            DocMapCampaignResources= new List<Document>();  
            DocMapCampaignNetworkService= new List<Document>();            
            DocMapCampaignMobileService= new List<Document>();             
            DocMapCampaignHostingService= new List<Document>();            
            DocMapCampaignBiFold= new List<Document>();                                 
            DocMapProposalResources= new List<Document>();
            DocMapDevDocumentation = new List<Document>();
            keyMapURL = new  Map<String, String>();            
            keyMapMobileURL = new  Map<String, String>();            
            keyMapHostingURL = new  Map<String, String>();             
            keyMapBiFoldURL = new  Map<String, String>(); 
            DocMapAVPNSalesReources = new List<Document>();
            DocMapAVPNTechnicalInfo = new List<Document>();
            DocMapAVPNGetStarted = new List<Document>();
            DocMapAVPNPricing = new List<Document>();   
            DocMapMISSales = new List<Document>(); 
            DocMapMISTechnical = new List<Document>(); 
            DocMapMISGet = new List<Document>(); 
            DocMapMISPricing = new List<Document>(); 
            DocMapASESales = new List<Document>(); 
            DocMapASETechnical = new List<Document>(); 
            DocMapASEGet = new List<Document>(); 
            DocMapASEPricing = new List<Document>(); 
            DocMapSEGSales = new List<Document>(); 
            DocMapSEGTechnical = new List<Document>(); 
            DocMapSEGGet = new List<Document>(); 
            DocMapSEGPricing = new List<Document>();     
            DocMapWWANView1 = new List<Document>();
            DocMapWWANView2 = new List<Document>();
            DocMapWWANView3 = new List<Document>();
            DocMapWWANView4 = new List<Document>(); 
            DocMapWWANView5 = new List<Document>();     
            DocMapWWANSales = new List<Document>(); 
            DocMapWWANSalesBusiness = new List<Document>(); 
            DocMapWWANSalesAccess = new List<Document>(); 
            DocMapWWANSalesCommercial = new List<Document>(); 
            DocMapWWANTechnicalBusiness = new List<Document>(); 
            DocMapWWANTechnicalAccess = new List<Document>(); 
            DocMapWWANTechnicalCommercial = new List<Document>(); 
            DocMapWWANGet = new List<Document>(); 
            DocMapWWANPricing = new List<Document>();             
            DocMapGROWGuides = new List<Document>();             
            DocMapCWSSales = new List<Document>(); 
            DocMapCWSTechnical = new List<Document>(); 
            DocMapCWSGet = new List<Document>(); 
            DocMapCWSPricing = new List<Document>();  
            DocMapNetBSales = new List<Document>(); 
            DocMapNetBGet = new List<Document>(); 
            DocMapNetBPricing = new List<Document>();  
            DocMapCOLOSales = new List<Document>(); 
            DocMapCOLOTechnical = new List<Document>(); 
            DocMapCOLOGet = new List<Document>(); 
            DocMapCOLOPricing = new List<Document>();  
            DocMapSalesEnable = new List<Document>();  
            DocMapIOTCCSales= new List<Document>();
            DocMapIOTCCTech= new List<Document>();
            DocMapIOTCVSales= new List<Document>();
            DocMapIOTCVTech= new List<Document>();
            DocMapIOTSCPSale= new List<Document>();
            DocMapIOTSCRetail= new List<Document>();
            DocMapIOTSCRetail2= new List<Document>();
            DocMapIOTSCContainer= new List<Document>();
            DocMapIOTAssess= new List<Document>();
            DocMapIOTStart= new List<Document>();
            DocMapIOTPricing= new List<Document>();   
            DocMapFlexWareSales= new List<Document>();   
            DocMapFlexWareTechnical= new List<Document>();   
            DocMapFlexWareGet= new List<Document>();   
            DocMapFlexWarePricing= new List<Document>();
            DocMapDESales= new List<Document>();   
            DocMapDETechnical= new List<Document>();   
            DocMapDEGet= new List<Document>();               
            //END                      
            //Changes by khalid CRC 11/29        
            if(folderId!=null && folderId.size()>0){            
                for(Document doc : [select id,URL,type,name,description,DeveloperName,keywords from Document where Document.FolderId =: folderId[0].id]){
                    DocURL = 'https://'+pageUrl+'/servlet/servlet.FileDownload?file='+doc.Id;
                    fileURL  = 'https://'+pageUrl+'/servlet/servlet.FileDownload?file=';
                    if(DocumentMap.containsKey(doc.DeveloperName)==false){
                        DocumentMap.put(doc.DeveloperName,DocURL);
                    }                    
            // Added by Eliza for US615321 Mobility Pages document management on 03/29/2016
           if(doc.DeveloperName==sec.Bulk_IRU_FAN_Request_Sheet__c){docId= doc.id;}          // Bulk_IRU_FAN_Request_Sheet
           if(doc.keywords==sec.IFR_Infographic__c){docId= doc.id;}          // IFR_Infographic           
           if(doc.keywords==sec.Overview_BreakingNews__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE); String key = parts[parts.size()-1];keyMapOverview.put(Integer.ValueOf(key),doc); listOverview.add(Integer.ValueOf(key));} //Overview_BreakingNews
           if(doc.keywords==sec.LearMore_Training_HelpfulLinks__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapTraining.put(Integer.ValueOf(key),doc);listTraining.add(Integer.ValueOf(key));}} //LearMore_Training_HelpfulLinks
           if(doc.keywords==sec.LearnMore_EnablementPlaybook__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapPlaybook.put(Integer.ValueOf(key),doc);listPlaybook.add(Integer.ValueOf(key));}}   //LearnMore_EnablementPlaybook        
           if(doc.keywords==sec.LearnMore_Equipment_Devices__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapDevices.put(Integer.ValueOf(key),doc);listDevices.add(Integer.ValueOf(key));}} //LearnMore_Equipment_Devices
           if(doc.keywords==sec.LearnMore_Equipment_Accessories__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapAccessories.put(Integer.ValueOf(key),doc);listAccessories.add(Integer.ValueOf(key));}} //LearnMore_Equipment_Accessories
           if(doc.keywords==sec.LearnMore_Equipment_DevicePurchasing__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapPurchasing.put(Integer.ValueOf(key),doc);listPurchasing.add(Integer.ValueOf(key));}}  //LearnMore_Equipment_DevicePurchasing         
           if(doc.keywords==sec.LearnMore_Rateplans_Pooling__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapPooling.put(Integer.ValueOf(key),doc);listPooling.add(Integer.ValueOf(key));}}  //LearnMore_Rateplans_Pooling
           if(doc.keywords==sec.LearnMore_Rateplans_BusinessConnect__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapConnect.put(Integer.ValueOf(key),doc);listConnect.add(Integer.ValueOf(key));}} //LearnMore_Rateplans_BusinessConnect
           if(doc.keywords==sec.LearnMore_Rateplans_BusinessPooled__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapPooled.put(Integer.ValueOf(key),doc);listPooled.add(Integer.ValueOf(key));}} //LearnMore_Rateplans_BusinessPooled
           if(doc.keywords==sec.LearnMore_Rateplans_Sharing__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapSharing.put(Integer.ValueOf(key),doc);listSharing.add(Integer.ValueOf(key));}}     //LearnMore_Rateplans_Sharing
           if(doc.keywords==sec.LearnMore_Rateplans_Individual__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapIndividual.put(Integer.ValueOf(key),doc);listIndividual.add(Integer.ValueOf(key));}}  //LearnMore_Rateplans_Individual
           if(doc.keywords==sec.LearnMore_International_TalkText__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapTalkText.put(Integer.ValueOf(key),doc);listTalkText.add(Integer.ValueOf(key));}}  //LearnMore_International_TalkText
           if(doc.keywords==sec.LearnMore_International_Travel__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapTravel.put(Integer.ValueOf(key),doc);listTravel.add(Integer.ValueOf(key));}} //LearnMore_International_Travel
           if(doc.keywords==sec.LearnMore_International_HelpfulLinks__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapHelpfulLinks.put(Integer.ValueOf(key),doc);listHelpfulLinks.add(Integer.ValueOf(key));}}   //LearnMore_International_HelpfulLinks
           if(doc.keywords==sec.Start_UseCases__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapUseCases.put(Integer.ValueOf(key),doc);listUseCases.add(Integer.ValueOf(key));}}        //Start_UseCases
           if(doc.keywords==sec.Start_Sales__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapSales.put(Integer.ValueOf(key),doc);listSales.add(Integer.ValueOf(key));}} //Start_Sales
           if(doc.keywords==sec.Start_Helpful__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapStartHelpful.put(Integer.ValueOf(key),doc);listStartHelpful.add(Integer.ValueOf(key));}}   //Start_Helpful
           if(doc.keywords==sec.Pricing__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapPricing.put(Integer.ValueOf(key),doc);listPricing.add(Integer.ValueOf(key));}}            //Pricing
           if(doc.keywords==sec.EPTT_Learn_Sales__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapEPTTLearnSales.put(Integer.ValueOf(key),doc);listEPTTLearnSales.add(Integer.ValueOf(key));}}  //EPTT_Learn_Sales          
           if(doc.keywords==sec.EPTT_Learn_UseCases__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapEPTTLearnUseCases.put(Integer.ValueOf(key),doc);listEPTTLearnUseCases.add(Integer.ValueOf(key));}}  //EPTT_Learn_UseCases                 
           if(doc.keywords==sec.EPTT_Learn_SalesFleet__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapEPTTLearnSalesFleet.put(Integer.ValueOf(key),doc);listEPTTLearnSalesFleet.add(Integer.ValueOf(key));}}  //EPTT_Learn_SalesFleet                
           if(doc.keywords==sec.EPTT_Start__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapEPTTStart.put(Integer.ValueOf(key),doc);listEPTTStart.add(Integer.ValueOf(key));}}          //EPTT_Start  
           if(doc.keywords==sec.EPTT_Pricing__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapEPTTPricing.put(Integer.ValueOf(key),doc);listEPTTPricing.add(Integer.ValueOf(key));}}  //EPTT_Pricing          
           if(doc.keywords==sec.FS_Learn_Sales__c){List<String> parts = doc.DeveloperName.split('_');String key = parts[parts.size()-1];if(key.isNumeric()){keyMapFSLearnSales.put(Integer.ValueOf(key),doc);listFSLearnSales.add(Integer.ValueOf(key));}}  //FS_Learn_Sales          
           if(doc.keywords==sec.FS_Learn_SalesFleet__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapFSLearnSalesFleet.put(Integer.ValueOf(key),doc);listFSLearnSalesFleet.add(Integer.ValueOf(key));}}  //FS_Learn_SalesFleet                
           if(doc.keywords==sec.FS_Learn_Technical__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapFSLearnTechnical.put(Integer.ValueOf(key),doc);listFSLearnTechnical.add(Integer.ValueOf(key));}}  //FS_Learn_Technical                 
           if(doc.keywords==sec.FS_Learn_TechnicalFleet__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapFSLearnTechnicalFleet.put(Integer.ValueOf(key),doc);listFSLearnTechnicalFleet.add(Integer.ValueOf(key));}}  //FS_Learn_TechnicalFleet                           
           if(doc.keywords==sec.FS_Start__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapFSStart.put(Integer.ValueOf(key),doc);listFSStart.add(Integer.ValueOf(key));}}          //FS_Start  
           if(doc.keywords==sec.FS_Pricing__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapFSPricing.put(Integer.ValueOf(key),doc);listFSPricing.add(Integer.ValueOf(key));}}  //FS_Pricing          
           if(doc.keywords==sec.IA_Pricing__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapIAPricing.put(Integer.ValueOf(key),doc);listIAPricing.add(Integer.ValueOf(key));} }  //IA_Pricing         
           if(doc.keywords==sec.IA_Resources_Sales__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapIASales.put(Integer.ValueOf(key),doc);listIASales.add(Integer.ValueOf(key));} }  //IA_Resources_Sales                   
           if(doc.keywords==sec.IA_Resources_Technical__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapIATechnical.put(Integer.ValueOf(key),doc);listIATechnical.add(Integer.ValueOf(key));}}   //IA_Resources_Technical                   
           if(doc.keywords==sec.IFR_Pricing__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapIFRPricing.put(Integer.ValueOf(key),doc);listIFRPricing.add(Integer.ValueOf(key));} }  //IFR_Pricing         
           if(doc.keywords==sec.IFR_Resources_Sales__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapIFRSales.put(Integer.ValueOf(key),doc);listIFRSales.add(Integer.ValueOf(key));} }  //IFR_Resources_Sales                   
           if(doc.keywords==sec.IFR_Resources_Technical__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapIFRTechnical.put(Integer.ValueOf(key),doc);listIFRTechnical.add(Integer.ValueOf(key));}}   //IFR_Resources_Technical          
           if(doc.keywords==sec.API_Developer_Documentation__c || doc.keywords!=null){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapDevDocumentation.put(Integer.ValueOf(key),doc);listDevDocumentation.add(Integer.ValueOf(key));}} //Developers_Documentation           
           if(doc.keywords==sec.ANIRA_Pricing__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapANIRAPricing.put(Integer.ValueOf(key),doc);listANIRAPricing.add(Integer.ValueOf(key));} }  //ANIRA_Pricing                   
           if(doc.keywords==sec.ANIRA_Resources_Sales__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapANIRASales.put(Integer.ValueOf(key),doc);listANIRASales.add(Integer.ValueOf(key));}  } //ANIRA_Resources_Sales                   
           if(doc.keywords==sec.ANIRA_Resources_Technical__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapANIRATechnical.put(Integer.ValueOf(key),doc);listANIRATechnical.add(Integer.ValueOf(key));}}   //ANIRA_Resources_Technical                   
           if(doc.keywords==sec.NBFW_Pricing__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapNBFWPricing.put(Integer.ValueOf(key),doc);listNBFWPricing.add(Integer.ValueOf(key));}}   //NBFW_Pricing                   
           if(doc.keywords==sec.NBFW_Resources_Sales__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapNBFWSales.put(Integer.ValueOf(key),doc);listNBFWSales.add(Integer.ValueOf(key));} }  //NBFW_Resources_Sales                   
           if(doc.keywords==sec.NBFW_Resources_Technical__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapNBFWTechnical.put(Integer.ValueOf(key),doc);listNBFWTechnical.add(Integer.ValueOf(key));} }  //NBFW_Resources_Technical                                        
           if(doc.keywords==sec.Proposal_Additional_Resources__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapProposalResources.put(Integer.ValueOf(key),doc);listProposalResources.add(Integer.ValueOf(key));}}   //Proposal_Additional_Resources                  
           if(doc.keywords==sec.Campaign_Additional_Resources__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapCampaignResources.put(Integer.ValueOf(key),doc);listCampaignResources.add(Integer.ValueOf(key));} }  //Campaign_Additional_Resources             
           if(doc.keywords==sec.Sales_Resources__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapAVPNSalesReources.put(Integer.ValueOf(key),doc);listAVPNSalesReources.add(Integer.ValueOf(key));}}   //AVPNSalesResources               
           if(doc.keywords==sec.Technical_Information__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapAVPNTechnicalInfo.put(Integer.ValueOf(key),doc);listAVPNTechnicalInfo.add(Integer.ValueOf(key));}}   //AVPNTechnicalInfo                   
           if(doc.keywords==sec.Get_Started__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapAVPNGetStarted.put(Integer.ValueOf(key),doc);listAVPNGetStarted.add(Integer.ValueOf(key));}}   //NBFW_Pricing                   
           if(doc.keywords==sec.AVPN_Pricing__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapAVPNPricing.put(Integer.ValueOf(key),doc);listAVPNPricing.add(Integer.ValueOf(key));} }  //NBFW_Pricing                   
           if(doc.keywords==sec.MIS_Sales__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapMISSales.put(Integer.ValueOf(key),doc);listMISSales.add(Integer.ValueOf(key));} }  //MIS_Sales                   
           if(doc.keywords==sec.MIS_Technical__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapMISTechnical.put(Integer.ValueOf(key),doc);listMISTechnical.add(Integer.ValueOf(key));} }  //MIS_Sales                   
           if(doc.keywords==sec.MIS_Get__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapMISGet.put(Integer.ValueOf(key),doc);listMISGet.add(Integer.ValueOf(key));} }  //MIS_Sales                   
           if(doc.keywords==sec.MIS_Pricing__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapMISPricing.put(Integer.ValueOf(key),doc);listMISPricing.add(Integer.ValueOf(key));} }  //MIS_Sales                   
           if(doc.keywords==sec.ASE_Sales__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapASESales.put(Integer.ValueOf(key),doc);listASESales.add(Integer.ValueOf(key));} }  //ASE_Sales                   
           if(doc.keywords==sec.ASE_Technical__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapASETechnical.put(Integer.ValueOf(key),doc);listASETechnical.add(Integer.ValueOf(key));} }  //ASE_Technical                   
           if(doc.keywords==sec.ASE_Get__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapASEGet.put(Integer.ValueOf(key),doc);listASEGet.add(Integer.ValueOf(key));} }  //ASE_Start                   
           if(doc.keywords==sec.ASE_Pricing__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapASEPricing.put(Integer.ValueOf(key),doc);listASEPricing.add(Integer.ValueOf(key));} }  //ASE_Pricing                   
           if(doc.keywords==sec.SEG_Sales__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapSEGSales.put(Integer.ValueOf(key),doc);listSEGSales.add(Integer.ValueOf(key));} }  //SEG_Sales                   
           if(doc.keywords==sec.SEG_Technical__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapSEGTechnical.put(Integer.ValueOf(key),doc);listSEGTechnical.add(Integer.ValueOf(key));} }  //SEG_Technical                   
           if(doc.keywords==sec.SEG_Get__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapSEGGet.put(Integer.ValueOf(key),doc);listSEGGet.add(Integer.ValueOf(key));} }  //SEG_Start                   
           if(doc.keywords==sec.SEG_Pricing__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapSEGPricing.put(Integer.ValueOf(key),doc);listSEGPricing.add(Integer.ValueOf(key));} }  //SEG_Pricing
           if(doc.keywords==sec.WWAN_Overview1__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapWWANView1.put(Integer.ValueOf(key),doc);listWWANView1.add(Integer.ValueOf(key));} }  //WWAN_View1    
           if(doc.keywords==sec.WWAN_Overview2__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapWWANView2.put(Integer.ValueOf(key),doc);listWWANView2.add(Integer.ValueOf(key));} }  //WWAN_View2    
           if(doc.keywords==sec.WWAN_Overview3__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapWWANView3.put(Integer.ValueOf(key),doc);listWWANView3.add(Integer.ValueOf(key));} }  //WWAN_View3    
           if(doc.keywords==sec.WWAN_Overview4__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapWWANView4.put(Integer.ValueOf(key),doc);listWWANView4.add(Integer.ValueOf(key));} }  //WWAN_View4    
           if(doc.keywords==sec.WWAN_Overview5__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapWWANView5.put(Integer.ValueOf(key),doc);listWWANView5.add(Integer.ValueOf(key));} }  //WWAN_View5    
           if(doc.keywords==sec.WWAN_Sales__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapWWANSales.put(Integer.ValueOf(key),doc);listWWANSales.add(Integer.ValueOf(key));} }  //WWAN_Sales                   
           if(doc.keywords==sec.WWAN_SalesBusiness__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapWWANSalesBusiness.put(Integer.ValueOf(key),doc);listWWANSalesBusiness.add(Integer.ValueOf(key));} }  //WWAN_Sales                   
           if(doc.keywords==sec.WWAN_SalesAccess__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapWWANSalesAccess.put(Integer.ValueOf(key),doc);listWWANSalesAccess.add(Integer.ValueOf(key));} }  //WWAN_Sales                   
           if(doc.keywords==sec.WWAN_SalesCommercial__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapWWANSalesCommercial.put(Integer.ValueOf(key),doc);listWWANSalesCommercial.add(Integer.ValueOf(key));} }  //WWAN_Sales                   
           if(doc.keywords==sec.WWAN_TechnicalBusiness__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapWWANTechnicalBusiness.put(Integer.ValueOf(key),doc);listWWANTechnicalBusiness.add(Integer.ValueOf(key));} }  //WWAN_Technical                   
           if(doc.keywords==sec.WWAN_TechnicalAccess__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapWWANTechnicalAccess.put(Integer.ValueOf(key),doc);listWWANTechnicalAccess.add(Integer.ValueOf(key));} }  //WWAN_Technical                   
           if(doc.keywords==sec.WWAN_TechnicalCommercial__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapWWANTechnicalCommercial.put(Integer.ValueOf(key),doc);listWWANTechnicalCommercial.add(Integer.ValueOf(key));} }  //WWAN_Technical                   
           if(doc.keywords==sec.WWAN_Get__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapWWANGet.put(Integer.ValueOf(key),doc);listWWANGet.add(Integer.ValueOf(key));} }  //WWAN_Start                   
           if(doc.keywords==sec.WWAN_Pricing__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapWWANPricing.put(Integer.ValueOf(key),doc);listWWANPricing.add(Integer.ValueOf(key));} }  //WWAN_Pricing                   
           if(doc.keywords==sec.Grow_Guides__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapGROWGuides.put(Integer.ValueOf(key),doc);listGROWGuides.add(Integer.ValueOf(key));} }  //GROW_Guides                              
           if(doc.keywords==sec.CWS_Sales__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapCWSSales.put(Integer.ValueOf(key),doc);listCWSSales.add(Integer.ValueOf(key));} }  //CWS_Sales                   
           if(doc.keywords==sec.CWS_Technical__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapCWSTechnical.put(Integer.ValueOf(key),doc);listCWSTechnical.add(Integer.ValueOf(key));} }  //CWS_Technical                   
           if(doc.keywords==sec.CWS_Get__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapCWSGet.put(Integer.ValueOf(key),doc);listCWSGet.add(Integer.ValueOf(key));} }  //CWS_Start                   
           if(doc.keywords==sec.CWS_Pricing__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapCWSPricing.put(Integer.ValueOf(key),doc);listCWSPricing.add(Integer.ValueOf(key));} }  //CWS_Pricing                   
           if(doc.keywords==sec.NetB_Sales__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapNetBSales.put(Integer.ValueOf(key),doc);listNetBSales.add(Integer.ValueOf(key));} }  //NetB_Sales                   
           if(doc.keywords==sec.NetB_Get__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapNetBGet.put(Integer.ValueOf(key),doc);listNetBGet.add(Integer.ValueOf(key));} }  //NetB_Start                   
           if(doc.keywords==sec.NetB_Pricing__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapNetBPricing.put(Integer.ValueOf(key),doc);listNetBPricing.add(Integer.ValueOf(key));} }  //NetB_Pricing                   
           if(doc.keywords==sec.Sales_Enable__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapSalesEnable.put(Integer.ValueOf(key),doc);listSalesEnable.add(Integer.ValueOf(key));} }  //Sales_Enable                  
           if(doc.keywords==sec.COLO_Sales__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapCOLOSales.put(Integer.ValueOf(key),doc);listCOLOSales.add(Integer.ValueOf(key));} }  //COLO_Sales                   
           if(doc.keywords==sec.COLO_Technical__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapCOLOTechnical.put(Integer.ValueOf(key),doc);listCOLOTechnical.add(Integer.ValueOf(key));} }  //COLO_Technical                   
           if(doc.keywords==sec.COLO_Start__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapCOLOGet.put(Integer.ValueOf(key),doc);listCOLOGet.add(Integer.ValueOf(key));} }  //COLO_Start                   
           if(doc.keywords==sec.COLO_Pricing__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapCOLOPricing.put(Integer.ValueOf(key),doc);listCOLOPricing.add(Integer.ValueOf(key));} }  //COLO_Pricing                   
           if(doc.keywords==sec.Network_Services__c){List<String> dName = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String slug = dName[dName.size()-1];String url = MarketingToolKitURL+'/?companyId='+manuplateStringForEncryption(SPAccountID)+'&level='+manuplateStringForEncryption(CurrentTier)+'&slug='+manuplateStringForEncryption(slug);  if(doc.type=='URL'){keyMapAssignment.put(doc.DeveloperName,url);} if(doc.type!='URL'){List<String> parts = doc.DeveloperName.split('_');String key = parts[parts.size()-1];if(key.isNumeric()){keyMapCampaignNetworkService.put(Integer.ValueOf(key),doc);listAssignment.add(doc.DeveloperName);listCampaignNetworkService.add(Integer.ValueOf(key));}}}      
           if(doc.keywords==sec.Mobile_Services__c){List<String> dName = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String slug = dName[dName.size()-1];String url = MarketingToolKitURL+'/?companyId='+manuplateStringForEncryption(SPAccountID)+'&level='+manuplateStringForEncryption(CurrentTier)+'&slug='+manuplateStringForEncryption(slug); if(doc.type=='URL'){keyMapMobileAssignment.put(doc.DeveloperName,url);}if(doc.type!='URL'){List<String> parts = doc.DeveloperName.split('_');String key = parts[parts.size()-1];if(key.isNumeric()){keyMapCampaignMobileService.put(Integer.ValueOf(key),doc);listMobileAssignment.add(doc.DeveloperName);listCampaignMobileService.add(Integer.ValueOf(key));}}}//Mobile_Services                 
           if(doc.keywords==sec.Hosting_Services__c){List<String> dName = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String slug = dName[dName.size()-1];String url = MarketingToolKitURL+'/?companyId='+manuplateStringForEncryption(SPAccountID)+'&level='+manuplateStringForEncryption(CurrentTier)+'&slug='+manuplateStringForEncryption(slug);if(doc.type=='URL'){keyMapHostingAssignment.put(doc.DeveloperName,url);}if(doc.type!='URL'){List<String> parts = doc.DeveloperName.split('_');String key = parts[parts.size()-1];if(key.isNumeric()){keyMapCampaignHostingService.put(Integer.ValueOf(key),doc);listHostingAssignment.add(doc.DeveloperName);listCampaignHostingService.add(Integer.ValueOf(key));}}}//Hosting_Services 
           if(doc.keywords==sec.Bi_fold__c){List<String> dName = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String slug = dName[dName.size()-1]; System.debug('Bifold slug value=='+slug);String url = MarketingToolKitURL+'/?companyId='+manuplateStringForEncryption(SPAccountID)+'&level='+manuplateStringForEncryption(CurrentTier)+'&slug='+manuplateStringForEncryption(slug); if(doc.type=='URL'){keyMapBiFoldAssignment.put(doc.DeveloperName,url);}if(doc.type!='URL'){List<String> parts = doc.DeveloperName.split('_');String key = parts[parts.size()-1];if(key.isNumeric()){keyMapCampaignBiFold.put(Integer.ValueOf(key),doc);listBiFoldAssignment.add(doc.DeveloperName);listCampaignBiFold.add(Integer.ValueOf(key));}}}//Bi_fold 
           if(doc.keywords==sec.IOT_Learn_CC_Sales__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapIOTCCSales.put(Integer.ValueOf(key),doc);listIOTCCSales.add(Integer.ValueOf(key));}}                 
           if(doc.keywords==sec.IOT_Learn_CC_Tech__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapIOTCCTech.put(Integer.ValueOf(key),doc);listIOTCCTech.add(Integer.ValueOf(key));}}  if(doc.keywords==sec.IOT_Learn_CV_Sales__c){List<String> parts = doc.DeveloperName.split('_');String key = parts[parts.size()-1];if(key.isNumeric()){keyMapIOTCVSales.put(Integer.ValueOf(key),doc);listIOTCVSales.add(Integer.ValueOf(key));}}        
           if(doc.keywords==sec.IOT_Learn_CV_Tech__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapIOTCVTech.put(Integer.ValueOf(key),doc);listIOTCVTech.add(Integer.ValueOf(key));}}
           if(doc.keywords==sec.IOT_Learn_SC_PSale__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapIOTSCPSale.put(Integer.ValueOf(key),doc);listIOTSCPSale.add(Integer.ValueOf(key));}}
           if(doc.keywords==sec.IOT_Learn_SC_Retail__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapIOTSCRetail.put(Integer.ValueOf(key),doc);listIOTSCRetail.add(Integer.ValueOf(key));}}
           if(doc.keywords==sec.IOT_Learn_SC_Retail2__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapIOTSCRetail2.put(Integer.ValueOf(key),doc);listIOTSCRetail2.add(Integer.ValueOf(key));}}
           if(doc.keywords==sec.IOT_Learn_SC_Container__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapIOTSCContainer.put(Integer.ValueOf(key),doc);listIOTSCContainer.add(Integer.ValueOf(key));}}
           if(doc.keywords==sec.IOT_Assess__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapIOTAssess.put(Integer.ValueOf(key),doc);listIOTAssess.add(Integer.ValueOf(key));} }          //IOT_Assess          
           if(doc.keywords==sec.IOT_Start__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapIOTStart.put(Integer.ValueOf(key),doc);listIOTStart.add(Integer.ValueOf(key));} }          //IOT_Start 
           if(doc.keywords==sec.IOT_Pricing__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapIOTPricing.put(Integer.ValueOf(key),doc);listIOTPricing.add(Integer.ValueOf(key));} }  //IOT_Pricing                   
           if(doc.keywords==sec.FlexWareSales__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapFlexWareSales.put(Integer.ValueOf(key),doc);listFlexWareSales.add(Integer.ValueOf(key));} }  //FlexWareSales                   
           if(doc.keywords==sec.FlexWareTechnical__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapFlexWareTechnical.put(Integer.ValueOf(key),doc);listFlexWareTechnical.add(Integer.ValueOf(key));} }  //FlexWareTechnical                   
           if(doc.keywords==sec.FlexWareGet__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapFlexWareGet.put(Integer.ValueOf(key),doc);listFlexWareGet.add(Integer.ValueOf(key));} }  //FlexWareGet                  
           if(doc.keywords==sec.FlexWarePricing__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapFlexWarePricing.put(Integer.ValueOf(key),doc);listFlexWarePricing.add(Integer.ValueOf(key));} }  //FlexWarePricing                       
           if(doc.keywords==sec.DE_Sales__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapDESales.put(Integer.ValueOf(key),doc);listDESales.add(Integer.ValueOf(key));} }  //DESales                   
           if(doc.keywords==sec.DE_Technical__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapDETechnical.put(Integer.ValueOf(key),doc);listDETechnical.add(Integer.ValueOf(key));} }  //DETechnical                   
           if(doc.keywords==sec.DE_Get__c){List<String> parts = doc.DeveloperName.split(SpecialCharacterBuyflowConstant.UNDERSCORE);String key = parts[parts.size()-1];if(key.isNumeric()){keyMapDEGet.put(Integer.ValueOf(key),doc);listDEGet.add(Integer.ValueOf(key));} }  //DEGet                  
              } // END OF FOR LOOP                          
            } // END OF IF 
            // Campaign & Proposal Builder
            for(String docName: listAssignment){String s2 = docName.substringBeforeLast(SpecialCharacterBuyflowConstant.UNDERSCORE); keyMapURL.put(docName,keyMapAssignment.get(s2));}            
            for(String docName: listMobileAssignment){String s2 = docName.substringBeforeLast(SpecialCharacterBuyflowConstant.UNDERSCORE);keyMapMobileURL.put(docName,keyMapMobileAssignment.get(s2));}             
            for(String docName: listHostingAssignment){String s2 = docName.substringBeforeLast(SpecialCharacterBuyflowConstant.UNDERSCORE);keyMapHostingURL.put(docName,keyMapHostingAssignment.get(s2));}
            for(String docName: listBiFoldAssignment){String s2 = docName.substringBeforeLast(SpecialCharacterBuyflowConstant.UNDERSCORE);keyMapBiFoldURL.put(docName,keyMapBiFoldAssignment.get(s2));}
            //  Campaign & Proposal Builder           
            listOverview.sort();for(Integer i :listOverview) { DocMapOverview.add(keyMapOverview.get(i));}
            listTraining.sort();for(Integer i :listTraining) { DocMapTraining.add(keyMapTraining.get(i));}
            listPlaybook.sort();for(Integer  i :listPlaybook) { DocMapEnablementPlaybook.add(keyMapPlaybook.get(i));}            
            listPurchasing.sort();for(Integer i :listPurchasing){ DocMapDevicePurchasing.add(keyMapPurchasing.get(i));}
            listAccessories.sort();for(Integer  i :listAccessories){DocMapAccessories.add(keyMapAccessories.get(i));}
            listDevices.sort();for(Integer i :listDevices) { DocMapDevices.add(keyMapDevices.get(i));}            
            listPooling.sort();for(Integer i :listPooling) { DocMapPooling.add(keyMapPooling.get(i));}       
            listConnect.sort();for(Integer i :listConnect) { DocMapBusinessConnect.add(keyMapConnect.get(i));}            
            listPooled.sort();for(Integer i :listPooled) { DocMapBusinessPooled.add(keyMapPooled.get(i));}           
            listSharing.sort();for(Integer  i :listSharing) { DocMapSharing.add(keyMapSharing.get(i));}        
            listIndividual.sort();for(Integer i :listIndividual) { DocMapIndividual.add(keyMapIndividual.get(i));}                 
            listTalkText.sort();for(Integer i :listTalkText) { DocMapTalkText.add(keyMapTalkText.get(i));}     
            listTravel.sort();for(Integer i :listTravel) { DocMapTravel.add(keyMapTravel.get(i));}  
            listHelpfulLinks.sort();for(Integer i :listHelpfulLinks) { DocMapHelpfulLinks.add(keyMapHelpfulLinks.get(i));}            
            listUseCases.sort();for(Integer i :listUseCases) { DocMapUseCases.add(keyMapUseCases.get(i));}                 
            listSales.sort();for(Integer i :listSales) { DocMapSales.add(keyMapSales.get(i));}                    
            listStartHelpful.sort();for(Integer  i :listStartHelpful) { DocMapStartHelpful.add(keyMapStartHelpful.get(i));}              
            listPricing.sort();for(Integer i :listPricing) { DocMapPricing.add(keyMapPricing.get(i));}   
            listEPTTLearnSales.sort();for(Integer i :listEPTTLearnSales) { DocMapEPTTLearnSales.add(keyMapEPTTLearnSales.get(i));}
            listEPTTLearnUseCases.sort();for(Integer i :listEPTTLearnUseCases) { DocMapEPTTLearnUseCases.add(keyMapEPTTLearnUseCases.get(i));}            
            listEPTTLearnSalesFleet.sort();for(Integer i :listEPTTLearnSalesFleet) { DocMapEPTTLearnSalesFleet.add(keyMapEPTTLearnSalesFleet.get(i));}           
            listEPTTStart.sort();for(Integer i :listEPTTStart) { DocMapEPTTStart.add(keyMapEPTTStart.get(i));}
            listEPTTPricing.sort();for(Integer i :listEPTTPricing) { DocMapEPTTPricing.add(keyMapEPTTPricing.get(i));}         
            listFSLearnSales.sort();for(Integer i :listFSLearnSales) { DocMapFSLearnSales.add(keyMapFSLearnSales.get(i));}
            listFSLearnSalesFleet.sort();for(Integer i :listFSLearnSalesFleet) { DocMapFSLearnSalesFleet.add(keyMapFSLearnSalesFleet.get(i));}           
            listFSLearnTechnical.sort();for(Integer i :listFSLearnTechnical) { DocMapFSLearnTechnical.add(keyMapFSLearnTechnical.get(i));}            
            listFSLearnTechnicalFleet.sort();for(Integer i :listFSLearnTechnicalFleet) { DocMapFSLearnTechnicalFleet.add(keyMapFSLearnTechnicalFleet.get(i));}  
            listFSStart.sort();for(Integer i :listFSStart) { DocMapFSStart.add(keyMapFSStart.get(i));}
            listFSPricing.sort();for(Integer i :listFSPricing) { DocMapFSPricing.add(keyMapFSPricing.get(i));}   
            listIAPricing.sort();if(!AIAConsumerEligibility){if(listIAPricing.size()>0) {listIAPricing.remove(1);listIAPricing.remove(0);}}for(Integer i :listIAPricing) { DocMapIAPricing.add(keyMapIAPricing.get(i));}            
            listIASales.sort();for(Integer i :listIASales) { DocMapIASales.add(keyMapIASales.get(i));}
            listIATechnical.sort();for(Integer i :listIATechnical) { DocMapIATechnical.add(keyMapIATechnical.get(i));}           
            listIFRPricing.sort();for(Integer i :listIFRPricing) { DocMapIFRPricing.add(keyMapIFRPricing.get(i));}            
            listIFRSales.sort();for(Integer i :listIFRSales) { DocMapIFRSales.add(keyMapIFRSales.get(i));}
            listIFRTechnical.sort();for(Integer i :listIFRTechnical) { DocMapIFRTechnical.add(keyMapIFRTechnical.get(i));}
            listDevDocumentation.sort();for(Integer i :listDevDocumentation) { DocMapDevDocumentation.add(keyMapDevDocumentation.get(i));}
            listANIRAPricing.sort();for(Integer i :listANIRAPricing) { DocMapANIRAPricing.add(keyMapANIRAPricing.get(i));}           
            listANIRASales.sort();for(Integer i :listANIRASales) { DocMapANIRASales.add(keyMapANIRASales.get(i));}           
            listANIRATechnical.sort();for(Integer i :listANIRATechnical) { DocMapANIRATechnical.add(keyMapANIRATechnical.get(i));} 
            listNBFWPricing.sort();for(Integer i :listNBFWPricing) { DocMapNBFWPricing.add(keyMapNBFWPricing.get(i));}           
            listNBFWSales.sort();for(Integer i :listNBFWSales) { DocMapNBFWSales.add(keyMapNBFWSales.get(i));}           
            listNBFWTechnical.sort();for(Integer i :listNBFWTechnical) { DocMapNBFWTechnical.add(keyMapNBFWTechnical.get(i));}  
            listCampaignResources.sort();for(Integer i :listCampaignResources) { DocMapCampaignResources.add(keyMapCampaignResources.get(i));}                      
            listCampaignNetworkService.sort();for(Integer i :listCampaignNetworkService) { DocMapCampaignNetworkService.add(keyMapCampaignNetworkService.get(i));}                                   
            listProposalResources.sort();for(Integer i :listProposalResources) { DocMapProposalResources.add(keyMapProposalResources.get(i));}
            listCampaignMobileService.sort();for(Integer i :listCampaignMobileService) { DocMapCampaignMobileService.add(keyMapCampaignMobileService.get(i));}  
            listCampaignHostingService.sort();for(Integer i :listCampaignHostingService) { DocMapCampaignHostingService.add(keyMapCampaignHostingService.get(i));} 
            listCampaignBiFold.sort();for(Integer i :listCampaignBiFold) { DocMapCampaignBiFold.add(keyMapCampaignBiFold.get(i));}
            listAVPNSalesReources.sort();for(Integer i :listAVPNSalesReources) { DocMapAVPNSalesReources.add(keyMapAVPNSalesReources.get(i));}                                                                               
            listAVPNTechnicalInfo.sort();for(Integer i :listAVPNTechnicalInfo) { DocMapAVPNTechnicalInfo.add(keyMapAVPNTechnicalInfo.get(i));}                                                                               
            listAVPNGetStarted.sort();for(Integer i :listAVPNGetStarted) { DocMapAVPNGetStarted.add(keyMapAVPNGetStarted.get(i));}                                                                               
            listAVPNPricing.sort();for(Integer i :listAVPNPricing) { DocMapAVPNPricing.add(keyMapAVPNPricing.get(i));} 
            listMISSales.sort();for(Integer i :listMISSales) { DocMapMISSales.add(keyMapMISSales.get(i));}    
            listMISTechnical.sort();for(Integer i :listMISTechnical) { DocMapMISTechnical.add(keyMapMISTechnical.get(i));}    
            listMISGet.sort();for(Integer i :listMISGet) { DocMapMISGet.add(keyMapMISGet.get(i));}    
            listMISPricing.sort();for(Integer i :listMISPricing) { DocMapMISPricing.add(keyMapMISPricing.get(i));}  
            listASESales.sort();for(Integer i :listASESales) { DocMapASESales.add(keyMapASESales.get(i));}    
            listASETechnical.sort();for(Integer i :listASETechnical) { DocMapASETechnical.add(keyMapASETechnical.get(i));}    
            listASEGet.sort();for(Integer i :listASEGet) { DocMapASEGet.add(keyMapASEGet.get(i));}    
            listASEPricing.sort();for(Integer i :listASEPricing) { DocMapASEPricing.add(keyMapASEPricing.get(i));}  
            listSEGSales.sort();for(Integer i :listSEGSales) { DocMapSEGSales.add(keyMapSEGSales.get(i));}    
            listSEGTechnical.sort();for(Integer i :listSEGTechnical) { DocMapSEGTechnical.add(keyMapSEGTechnical.get(i));}    
            listSEGGet.sort();for(Integer i :listSEGGet) { DocMapSEGGet.add(keyMapSEGGet.get(i));}    
            listSEGPricing.sort();for(Integer i :listSEGPricing) { DocMapSEGPricing.add(keyMapSEGPricing.get(i));}            
            listWWANView1.sort();for(Integer i :listWWANView1) { DocMapWWANView1.add(keyMapWWANView1.get(i));} 
            listWWANView2.sort();for(Integer i :listWWANView2) { DocMapWWANView2.add(keyMapWWANView2.get(i));} 
            listWWANView3.sort();for(Integer i :listWWANView3) { DocMapWWANView3.add(keyMapWWANView3.get(i));} 
            listWWANView4.sort();for(Integer i :listWWANView4) { DocMapWWANView4.add(keyMapWWANView4.get(i));} 
            listWWANView5.sort();for(Integer i :listWWANView5) { DocMapWWANView5.add(keyMapWWANView5.get(i));}              
            listWWANSales.sort();for(Integer i :listWWANSales) { DocMapWWANSales.add(keyMapWWANSales.get(i));}    
            listWWANSalesBusiness.sort();for(Integer i :listWWANSalesBusiness) { DocMapWWANSalesBusiness.add(keyMapWWANSalesBusiness.get(i));}    
            listWWANSalesAccess.sort();for(Integer i :listWWANSalesAccess) { DocMapWWANSalesAccess.add(keyMapWWANSalesAccess.get(i));}    
            listWWANSalesCommercial.sort();for(Integer i :listWWANSalesCommercial) { DocMapWWANSalesCommercial.add(keyMapWWANSalesCommercial.get(i));}    
            listWWANTechnicalBusiness.sort();for(Integer i :listWWANTechnicalBusiness) { DocMapWWANTechnicalBusiness.add(keyMapWWANTechnicalBusiness.get(i));}    
            listWWANTechnicalAccess.sort();for(Integer i :listWWANTechnicalAccess) { DocMapWWANTechnicalAccess.add(keyMapWWANTechnicalAccess.get(i));} 
            listWWANTechnicalCommercial.sort();for(Integer i :listWWANTechnicalCommercial) { DocMapWWANTechnicalCommercial.add(keyMapWWANTechnicalCommercial.get(i));} 
            listWWANGet.sort();for(Integer i :listWWANGet) { DocMapWWANGet.add(keyMapWWANGet.get(i));}    
            listWWANPricing.sort();for(Integer i :listWWANPricing) { DocMapWWANPricing.add(keyMapWWANPricing.get(i));} 
            listGROWGuides.sort();for(Integer i :listGROWGuides) { DocMapGROWGuides.add(keyMapGROWGuides.get(i));} 
            listCWSSales.sort();for(Integer i :listCWSSales) { DocMapCWSSales.add(keyMapCWSSales.get(i));}    
            listCWSTechnical.sort();for(Integer i :listCWSTechnical) { DocMapCWSTechnical.add(keyMapCWSTechnical.get(i));}    
            listCWSGet.sort();for(Integer i :listCWSGet) { DocMapCWSGet.add(keyMapCWSGet.get(i));}    
            listCWSPricing.sort();for(Integer i :listCWSPricing) { DocMapCWSPricing.add(keyMapCWSPricing.get(i));}                      
            listCOLOSales.sort();for(Integer i :listCOLOSales) { DocMapCOLOSales.add(keyMapCOLOSales.get(i));}    
            listCOLOTechnical.sort();for(Integer i :listCOLOTechnical) { DocMapCOLOTechnical.add(keyMapCOLOTechnical.get(i));}    
            listCOLOGet.sort();for(Integer i :listCOLOGet) { DocMapCOLOGet.add(keyMapCOLOGet.get(i));}    
            listCOLOPricing.sort();for(Integer i :listCOLOPricing) { DocMapCOLOPricing.add(keyMapCOLOPricing.get(i));}                      
            listNetBSales.sort();for(Integer i :listNetBSales) { DocMapNetBSales.add(keyMapNetBSales.get(i));}    
            listNetBGet.sort();for(Integer i :listNetBGet) { DocMapNetBGet.add(keyMapNetBGet.get(i));}    
            listNetBPricing.sort();for(Integer i :listNetBPricing) { DocMapNetBPricing.add(keyMapNetBPricing.get(i));}                      
            listSalesEnable.sort();for(Integer i :listSalesEnable) { DocMapSalesEnable.add(keyMapSalesEnable.get(i));}  
            listIOTCCSales.sort();for(Integer i :listIOTCCSales) { DocMapIOTCCSales.add(keyMapIOTCCSales.get(i));}
            listIOTCCTech.sort();for(Integer i :listIOTCCTech) { DocMapIOTCCTech.add(keyMapIOTCCTech.get(i));}
            listIOTCVSales.sort();for(Integer i :listIOTCVSales) { DocMapIOTCVSales.add(keyMapIOTCVSales.get(i));}
            listIOTCVTech.sort();for(Integer i :listIOTCVTech) { DocMapIOTCVTech.add(keyMapIOTCVTech.get(i));}
            listIOTSCPSale.sort();for(Integer i :listIOTSCPSale) { DocMapIOTSCPSale.add(keyMapIOTSCPSale.get(i));}
            listIOTSCRetail.sort();for(Integer i :listIOTSCRetail) { DocMapIOTSCRetail.add(keyMapIOTSCRetail.get(i));}
            listIOTSCRetail2.sort();for(Integer i :listIOTSCRetail2) { DocMapIOTSCRetail2.add(keyMapIOTSCRetail2.get(i));}
            listIOTSCContainer.sort();for(Integer i :listIOTSCContainer) { DocMapIOTSCContainer.add(keyMapIOTSCContainer.get(i));}       
            listIOTAssess.sort();for(Integer i :listIOTAssess) { DocMapIOTAssess.add(keyMapIOTAssess.get(i));}
            listIOTStart.sort();for(Integer i :listIOTStart) { DocMapIOTStart.add(keyMapIOTStart.get(i));}
            listIOTPricing.sort();for(Integer i :listIOTPricing) { DocMapIOTPricing.add(keyMapIOTPricing.get(i));}      
            listFlexWareSales.sort();for(Integer i :listFlexWareSales) { DocMapFlexWareSales.add(keyMapFlexWareSales.get(i));}     
            listFlexWareTechnical.sort();for(Integer i :listFlexWareTechnical) { DocMapFlexWareTechnical.add(keyMapFlexWareTechnical.get(i));}     
            listFlexWareGet.sort();for(Integer i :listFlexWareGet) { DocMapFlexWareGet.add(keyMapFlexWareGet.get(i));}          
            listFlexWarePricing.sort();for(Integer i :listFlexWarePricing) { DocMapFlexWarePricing.add(keyMapFlexWarePricing.get(i));}                
            listDESales.sort();for(Integer i :listDESales) { DocMapDESales.add(keyMapDESales.get(i));}     
            listDETechnical.sort();for(Integer i :listDETechnical) { DocMapDETechnical.add(keyMapDETechnical.get(i));}     
            listDEGet.sort();for(Integer i :listDEGet) { DocMapDEGet.add(keyMapDEGet.get(i));}      
              // END           
            EncryptURlForProposalBuilder(); //Method added by Srikanth for Proposal Builder
        }
            catch (Exception e) {
            String exceptionString = ATTException.constructExceptionMessageString(e);
            ATTException.createException(System.Label.paramMissing, e.getTypeName(), exceptionString);                        
        }
    }
    //US615321 Mobility Pages document management

/* 
 Name: EncryptURlForProposalBuilder
 Description: 
 */ 
    public void EncryptURlForProposalBuilder(){
try{        
        //Stipping non-numeric prefix from SFDC_SP_Account_ID
        String regex = '[a-zA-Z]{1,}|\\-';
        String stripedSPAccountId = SPAccountID.replaceAll(regex, '');

        URLForProposalBuilderNav = MarketingToolKitURL+'/?c='+manuplateStringForEncryption(stripedSPAccountId)+'&u='+manuplateStringForEncryption(UserInfo.getUserName())+'&l='+manuplateStringForEncryption(CurrentTier)+'&slug='+manuplateStringForEncryption('proposal');
           }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                
            }
    }

/* 
 Name: manuplateStringForEncryption
 Description: 
 */ 
    public string manuplateStringForEncryption(String existingString){
        try{
        String newString;
        for(integer i=0; i< existingString.length();i++)  {
            if(existingString.length() < 112){          //Since Max length of characters is ony 100
                existingString = existingString + '~';
            }           
        }
        newString = existingString;
        Blob data = Blob.valueOf(newString);
        Blob encryptedValue = Crypto.encryptWithManagedIV('AES256', encryptedTokenKey, data);
        String var = EncodingUtil.base64Encode(encryptedValue);
        return var; 
    }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                return null;
            }                 
    }

   // Added method by Eliza to send email on IRU form submission 03/29/2016
/* 
 Name: sendEmail
 Description: 
 */ 
   public PageReference sendEmail(){  
   PageReference pageRef;                      
    try{         
          
        Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();    
        Messaging.EmailFileAttachment file1 = new Messaging.EmailFileAttachment();
        Messaging.EmailFileAttachment file2 = new Messaging.EmailFileAttachment();
        Messaging.EmailFileAttachment file3 = new Messaging.EmailFileAttachment();
        List<Messaging.EmailFileAttachment> fileList = new List<Messaging.EmailFileAttachment>();   
        String subject,body,body1,body2,body3,body4,body5,body6,body7,body8; 
        esFAN=esFAN!=null&&esFAN!=''?esFAN:'N/A';
        esBName=esBName!=null&&esBName!=''?esBName:'N/A';
        bName=bName!=null&&bName!=''?bName:'N/A';
        eDomain1=eDomain1!=null&&eDomain1!=''?eDomain1:'N/A';
        eDomain2=eDomain2!=null&&eDomain2!=''?', '+eDomain2:'';
        eDomain3=eDomain3!=null&&eDomain3!=''?', '+eDomain3:'';
        eDomain4=eDomain4!=null&&eDomain4!=''?', '+eDomain4:'';
        eDomain5=eDomain5!=null&&eDomain5!=''?', '+eDomain5:'';
        eDomain6=eDomain6!=null&&eDomain6!=''?', '+eDomain6:'';
        eDomain7=eDomain7!=null&&eDomain7!=''?', '+eDomain7:'';
        eDomain8=eDomain8!=null&&eDomain8!=''?', '+eDomain8:'';
        eDomain9=eDomain9!=null&&eDomain9!=''?', '+eDomain9:'';
        eDomain10=eDomain10!=null&&eDomain10!=''?', '+eDomain10:'';
        fname=fname!=null&&fname!=''?fname:'N/A';
        lname=lname!=null&&lname!=''?lname:'N/A';
        email=email!=null&&email!=''?email:'N/A';
        address=address!=null&&address!=''?address:'N/A';
        city=city!=null&&city!=''?city:'N/A';
        state=state!=null&&state!=''?state:'N/A';
        zcode=zcode!=null&&zcode!=''?zcode:'N/A';
        phno=phno!=null&&phno!=''?phno:'N/A';
        pName=pName!=null&&pName!=''?pName:'N/A';
        discount=discount!=null&&discount!=''?discount:'N/A';
        comments=comments!=null&&comments!=''?comments:'N/A';
        desp=desp!=null&&desp!=''?desp:'N/A';
        body1='Partner Exchange Team,'+'<br/><br/>'+'Please verify the discount percentage for this customer and submit a Profile Creation form to '+'<br>'+'the NBO Profiles team (NBOprofiles@att.com) to create a new IRU FAN under '+'<br>'+'this solution provider’s Mobility Agreement.'+'<br/><br/>';        
        body8='Partner Exchange Team,'+'<br/><br/>'+'Please refer to the collected form data to update existing end customer profile information.'+'<br/><br/>';
        body2='Name: '+userName+'<br/>'+'Email: '+userEmail+'<br/>'+'User Account: '+uAccount+'<br/>'+'Date Submitted: '+dateSubmitted+'<br/><br/>';
        body3='<b>End Customer Business Information:</b>'+'<br/>'+'Business Name: '+bName+'<br/>'+'EmailDomain: '+eDomain1+eDomain2+eDomain3+eDomain4+eDomain5+eDomain6+eDomain7+eDomain8+eDomain9+eDomain10+'<br/><br/>';
        body4='<b>End Customer Contact Information: </b>'+'<br/>'+'First Name:  '+fname+'<br>'+'Last Name:  '+lname+'<br>'+'Email:  '+email+'<br>'+'Address:  '+address+'<br>'+'City:  '+city+'<br>'+'State:  '+state+'<br>'+'ZipCode:  '+zcode+'<br>'+'Ph.No:  '+phno+'<br/><br/>';
        body5='<b>Existing End Customer Information:</b>'+'<br><br>'+'Existing Sponsorship FAN:  '+esFAN+'<br>'+'Existing Business Name:  '+esBName+'<br><br>';
                
        if(sdUpload1!=null){
        file1.setFileName(fileName1);
        file1.Body = sdUpload1;
        fileList.add(file1); 
        }
  
        if(sdUpload2!=null){
        file2.setFileName(fileName2);
        file2.Body = sdUpload2;
        fileList.add(file2); 
        }        
       
        if(isSAcct!=true){
            body6='<b>Additional Information:</b>'+'<br>'+'Customer has a Sponsorship Account with a competitor: No'+'<br/>';
        }
        else{
            body6='<b>Additional Information:</b>'+'<br>'+'Customer has a Sponsorship Account with a competitor: Yes'+'<br/>'+'Provider Name:  '+pName+'<br>'+'Discount:  '+discount+'<br>'+'Comments:  '+comments+'<br><br>';
        }
        if(isDiscount!=true){
            body7='Special discount request: No'+'<br>';
        }
        else{
            body7='Special discount request: Yes'+'<br>'+'Description:  '+desp+'<br>';
        }     
        
        
        if(esFAN!=NewStartConstant.NA && mulCustUpload==null){
            subject=NewStartConstant.EMPLOYEESPONSORSHIP_PROGRAM_REQUEST_TO_UPDATE_EXISTING_END_CUSTOMER_BY_x+userName; 
            body=body8+'<b>Update End Customer Form Submitted by:</b>'+'<br>'+body2+body5+'<b>Updated</b> '+body3+'<b>Updated</b> '+body4+body6+body7;
        }
        
        if(mulCustUpload==null && esFAN==NewStartConstant.NA){
            subject=NewStartConstant.EMPLOYEESPONSORSHIP_PROGRAM_REQUEST_TO_REGISTER_END_CUSTOMER_BY_x+userName; 
            body=body1+'<b>Register End Customer Form Submitted by:</b>'+'<br>'+body2+body3+body4+body6+body7;
        }  
        
        if(mulCustUpload!=null && esFAN==NewStartConstant.NA){
        file3.setFileName(mulFileName);
        file3.Body = mulCustUpload;
        fileList.add(file3);        
        subject=NewStartConstant.EMPLOYEESPONSORSHIP_PROGRAM_REQUEST_TO_REGISTER_MULTIPLE_END_CUSTOMER_BY_x+userName; 
        body=body1+'<b>Register Multiple End Customer Form Submitted by:</b>'+'<br>'+body2+'<br><br>'+NewStartConstant.PLEASEFIND_ATTACHED_MULTIPLE_CUSTOMER_INFORMATION+'<br>';
        } 
        
        // Following lines added by Eliza for IRU Employee Sponsorship form redesign
        DateTime d = Date.Today() ;
        String dateStr =  d.format('dd/mm/yyyy') ;
        string header = 'Cell, Label , Value \n';
        string row1 = header +'B5'+','+'Date Submitted (DD-MM-YY Format) *'+','+date.today().format()+'\n';
        string row2 = row1 +'B12'+','+'FAN Account Profile Name:'+','+bName+'\n';
        String agreementID;String mobilityL2;String name;String address;String city;String state;String zip;
        if (accountList.size()>0){
        agreementID = accountList[0].AgreementID__c;
        mobilityL2 = accountList[0].Mobility_L2_ID__c;
        name=accountList[0].name;
        address=accountList[0].Billing_Address__c;
        city=accountList[0].Billing_City__c;
        state=accountList[0].Billing_State__c;
        zip=accountList[0].Billing_Zip_Code__c;
        }
        agreementID = agreementID!=null&&agreementID!=SpecialCharacterBuyflowConstant.CONCAT?agreementID:SpecialCharacterBuyflowConstant.BLANK;        
        mobilityL2 = mobilityL2!=null&&mobilityL2!=SpecialCharacterBuyflowConstant.CONCAT?mobilityL2:SpecialCharacterBuyflowConstant.BLANK;
        string row3 = row2 +NewStartConstant.B14+SpecialCharacterBuyflowConstant.COMMA+NewStartConstant.AGREEMENTNAME_AND_NUMBER_x+SpecialCharacterBuyflowConstant.COMMA+agreementID+NewStartConstant.N1;
        string row4 = row3 +NewStartConstant.B16+SpecialCharacterBuyflowConstant.COMMA+NewStartConstant.LOCATIONACCOUNT_NUMBER_x+SpecialCharacterBuyflowConstant.COMMA+mobilityL2+NewStartConstant.N1;
        string row5 = row4 +NewStartConstant.B19+SpecialCharacterBuyflowConstant.COMMA+NewStartConstant.COMPANYE_MAIL_DOMAIN_x+SpecialCharacterBuyflowConstant.COMMA+eDomain1+NewStartConstant.N1;
        string row6 = row5 +NewStartConstant.B20+SpecialCharacterBuyflowConstant.COMMA+NewStartConstant.USERDEFINED_LABEL_1_OPTIONAL_x+eDomain2+NewStartConstant.N1;
        string row7 = row6 +NewStartConstant.B21+SpecialCharacterBuyflowConstant.COMMA+NewStartConstant.USERDEFINED_LABEL_2_OPTIONAL_x+eDomain3+NewStartConstant.N1;
        string row8 = row7 +NewStartConstant.B22+SpecialCharacterBuyflowConstant.COMMA+NewStartConstant.USERDEFINED_LABEL_3_OPTIONAL_x+eDomain4+NewStartConstant.N1;
        string row9 = row8 +NewStartConstant.B23+SpecialCharacterBuyflowConstant.COMMA+NewStartConstant.USERDEFINED_LABEL_4_OPTIONAL_x+eDomain5+NewStartConstant.N1;
        string row10 = row9 +NewStartConstant.B24+SpecialCharacterBuyflowConstant.COMMA+NewStartConstant.USERDEFINED_LABEL_5_OPTIONAL_x+eDomain6+NewStartConstant.N1;
        string row11= row10 +NewStartConstant.B25+SpecialCharacterBuyflowConstant.COMMA+NewStartConstant.USERDEFINED_LABEL_6_OPTIONAL_x+eDomain7+NewStartConstant.N1;
        string row12= row11+NewStartConstant.B26+SpecialCharacterBuyflowConstant.COMMA+NewStartConstant.USERDEFINED_LABEL_7_OPTIONAL_x+eDomain8+NewStartConstant.N1;
        string row13= row12+NewStartConstant.B27+SpecialCharacterBuyflowConstant.COMMA+NewStartConstant.USERDEFINED_LABEL_8_OPTIONAL_x+eDomain9+NewStartConstant.N1;
        string row14= row13+NewStartConstant.B28+SpecialCharacterBuyflowConstant.COMMA+NewStartConstant.USERDEFINED_LABEL_9_OPTIONAL_x+eDomain10+NewStartConstant.N1;
        string row15= row14+NewStartConstant.B30+SpecialCharacterBuyflowConstant.COMMA+NewStartConstant.BUSINESSNAME+SpecialCharacterBuyflowConstant.COMMA+name+NewStartConstant.N1;
        string row16= row15+NewStartConstant.B31+SpecialCharacterBuyflowConstant.COMMA+NewStartConstant.STREET+SpecialCharacterBuyflowConstant.COMMA+address+NewStartConstant.N1;
        string row17= row16+NewStartConstant.B32+SpecialCharacterBuyflowConstant.COMMA+NewStartConstant.CITYSTATE_ZIP+SpecialCharacterBuyflowConstant.COMMA+city+SpecialCharacterBuyflowConstant.BLANK+state+SpecialCharacterBuyflowConstant.BLANK+zip+NewStartConstant.N1;
        string row18= row17+NewStartConstant.B39+SpecialCharacterBuyflowConstant.COMMA+NewStartConstant.NAME_x2+SpecialCharacterBuyflowConstant.COMMA+fname+SpecialCharacterBuyflowConstant.BLANK+lname+NewStartConstant.N1;
        string row19= row18+NewStartConstant.B40+SpecialCharacterBuyflowConstant.COMMA+NewStartConstant.ADDRESS_x1+SpecialCharacterBuyflowConstant.COMMA+address+NewStartConstant.N1;
        string row20= row19+NewStartConstant.B41+SpecialCharacterBuyflowConstant.COMMA+NewStartConstant.CITYSTATE_ZIP_x+SpecialCharacterBuyflowConstant.COMMA+city+SpecialCharacterBuyflowConstant.BLANK+state+SpecialCharacterBuyflowConstant.BLANK+zcode+NewStartConstant.N1;
        string row21= row20+NewStartConstant.B42+SpecialCharacterBuyflowConstant.COMMA+NewStartConstant.EMAIL+SpecialCharacterBuyflowConstant.COMMA+email+NewStartConstant.N1;
        string row22= row21+NewStartConstant.B43+SpecialCharacterBuyflowConstant.COMMA+NewStartConstant.PHONENUMBER_x+SpecialCharacterBuyflowConstant.COMMA+phno+NewStartConstant.N1;
        string finalstr = row22;
        
        if(mulCustUpload==null){
        Messaging.EmailFileAttachment file4 = new Messaging.EmailFileAttachment();
        blob csvBlob = Blob.valueOf(finalstr);
        string csvname= NewStartConstant.IRUFORM_INPUT_CSV;
        file4.setFileName(csvname);
        file4.setBody(csvBlob);
        fileList.add(file4);
        }
        // End
        
        
        IRU_Email__c iEmail = IRU_Email__c.getvalues('eName'); 
        mail.setToAddresses(new String[]{iEmail.eList__c});   
        //mail.setToAddresses(new String[]{'ev099s@att.com'});        .
        mail.setSubject(subject);    
        if(fileList.size()>0)mail.setFileAttachments(fileList);                 
        mail.setHtmlBody(body);
        mail.setSenderDisplayName(userEmail);        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        
       if(esFAN!='N/A')pageRef = new PageReference('/apex/PortalDesign_Mobile?ThankYou=existing');
       if(esFAN=='N/A')pageRef = new PageReference('/apex/PortalDesign_Mobile?ThankYou=new'); 
       }
       catch(exception E){Apexpages.addMessages(E);}                   
       pageRef.setRedirect(true);
       return pageRef;           
     } //END           
}