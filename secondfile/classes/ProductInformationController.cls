/************************************************************************************** 
 Apex Class Name     : ProductInformationController
 Version             : 1.0 
 Created Date        : 13 Oct 2014
 Function            : This class tracks the constants
 Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sunil Kumar            10/13/2014              Original Version
*************************************************************************************/
/* 
 Name: ProductInformationController
 Type: Class 
 
 Description: 
 */ 
public class ProductInformationController {

    public boolean userBeginQuote{get; set;}
    public String quote { get; set; }
    public boolean ipflexSelected{ get; set; }
    public boolean ipflexSelected1{ get; set; }
    public String ipflexValue{ get; set; }
    // VARIABLES    
    //Dipendu//
    public boolean isWirelessProduct{ get; set; }
    public string radioButtonRedirect {get;set;}
    public string radioButtonRedirectJasper {get;set;}   //@Dipendu on 11/12/14 
    public String  customerReference{get;set;}   
    public Apttus_Proposal__Proposal__c quoteObj{get;set;}     
    public String quoteName{get;set;}
    public String tempQuoteName{get;set;} 
    public String productId{get;set;}
    public String productId1{get;set;}
    public string quoteId{get;set;}     
    public String productIdcheck{get;set;}  //@dipendu
    public String productNamecheck{get;set;} //@dipendu
    public String selectedTerm{get;set;}
    public String prodName{get;set;}
    public boolean aiacheckvalue{get;set;} 
    public boolean masterpricing{get;set;}
    public boolean camaction{get;set;}
    public String camEmail{get;set;}
    public String aiaradiovalue{get;set;}    
    //These are added for ASE
    public String selectedEthernetconfiguration{set;get;}
    public String selectedTrafficJurisdiction{set;get;}
    public boolean showProdAttr{get;set;}
    //
    private Map<Id,Product2> prodMap;
    public List<Product2> prodList;
    public List<ProductWrapper> pWrapperList{get;set;}    
    @TestVisible string[] prod_Code_Values;
    @TestVisible string[] prod_Code_To_Exclude_Values;
    boolean portaluserbool;
    
    //@Prem added for Login Dispatch
    public String encryptedUrl{get;set;}
    public String deEncryptedUrl{get;set;}
    public String deEncryptedUrlPI{get;set;}
    public String quoteNo{get;set;}
    public String mobileProdId{get;set;}
    public String typeOfFan{get;set;}
    public Boolean checkMobilityFlag{get;set;}
    public String ErrorMessage{ get; set; }
    public Admin_Control__c AdminControl{get;set;}
        
    public Apttus_Config2__ProductAttributeValue__c productAttributeValueInstance;
    
    //Added by RK: 11/27/2014
    public string productType {get;set;}
    //Added for disable/enable radio for wireless
    public Boolean checkWirelessFlag{get;set;}
    public Boolean isAIAProdChecked;
    public Boolean isASEProdChecked;
    public List<User> userlist{get;set;}
    public Boolean FirstTimeUser{get;set;}
    public Boolean MPSSigned{get;set;}
    public Boolean MPSUpdated{get;set;}
    public Boolean MPSNotSigned{get;set;}
    public date mpsAdminDateTime;
    public date mpsAccountDateTime;
    public date mpsAdminDate;
    public date mpsAccountDate;
    public Boolean CamAssigned{get;set;}
    public id accID ;
    public Boolean FirstTimeUserASE{get;set;}  
    public Date PromotionSimulationDate{get;set;}
    public Boolean isTestAccount{get;set;}
    public Boolean isAVPNChecked{get;set;}
    public Boolean isMISChecked{get;set;}
/* 
 Name: ProductInformationController
 Description: 
 */ 
    public  ProductInformationController(){
        Boolean isAniraProdChecked = false;
        Boolean isANIRAApttusActive = false;
       
        User userObj;
        prodName = SpecialCharacterConstant.CONCAT;
         if(!Test.isrunningTest()){
             userObj = [select id,accountid ,Begin_Quote__c,contactId from User where id = :UserInfo.getUserId()];
         }
         else  if(Test.isrunningTest()){
            userObj = [select id,accountid ,Begin_Quote__c,contactId from User limit 1];
         }
        userBeginQuote = userObj.Begin_Quote__c;
        if(userObj.contactId != NULL){
            enableWirelessRadio(userObj.contactId);
        }
        
        prodList = new List<Product2> ();       
        quoteObj = new Apttus_Proposal__Proposal__c();
        userlist = new List<User>();
        pWrapperList = new List<ProductWrapper>(); 
        selectedTerm =  ATT_Constant.TERM_3YEAR;
        aiaradiovalue = BuyflowConstant.BUSINESS;
        // Added by Anand M
        Prod_Code_Values = new List<String>();
        Prod_Code_To_Exclude_Values = new List<String>{BuyflowConstant.STAAS,BuyflowConstant.NBFW};
        
        //Teja: 12/8/2014 - DE86444 - Default Ethernet configuration not required
        //selectedEthernetconfiguration=BuyflowConstant.ETHERNETPRIVATE_LINE_POINT_TO_POINT_x;
        selectedTrafficJurisdiction=BuyflowConstant.INTERSTATE;
        showProdAttr = false;  
        ipflexSelected1  = false;  
        ipflexValue = BuyflowConstant.ADDAT_T_IP_FLEXIBLE_REACH;
        productAttributeValueInstance = new Apttus_Config2__ProductAttributeValue__c();

        //Dipendu//
        radioButtonRedirect = Mobile_Products__c.getValues('RingCentral radio button URL') != null ? Mobile_Products__c.getValues('RingCentral radio button URL').URL__c : '';
        radioButtonRedirectJasper = Mobile_Products__c.getValues('RingCentral radio button URL') != null ? Mobile_Products__c.getValues('RingCentral radio button URL').URL__c : '';     
       
     
        User currentLogged_User;
        if(!Test.isrunningTest()){
            currentLogged_User =[select id, Contact.Account.Anira_Product__c,Contact.Account.Wireless_Product__c,Contact.Account.isMIS__c,Contact.Account.isAVPN__c, Contact.Account.ASE_Product__c,Contact.Account.Test_Company__c,Contact.Account.Product_Trainings_Completed__c, Contact.Account.AIA_Consumer_Eligibility__c, Contact.Account.AIA_Master_Pricing_Schedule__c,accountid, Contact.Account.OwnerId,Contact.First_time_AIA__c,Contact.Account.AIA_MPS_Signing_Date__c,Contact.First_time_ASE__c,Contact.Account.AIA_Product__c from User Where Id=: UserInfo.getUserId()];
        }
        else if(Test.isrunningTest()){          
            currentLogged_User =[select id, Contact.Account.Anira_Product__c, Contact.Account.Wireless_Product__c,Contact.Account.isMIS__c,Contact.Account.isAVPN__c,Contact.Account.ASE_Product__c,Contact.Account.Test_Company__c,Contact.Account.Product_Trainings_Completed__c, Contact.Account.AIA_Consumer_Eligibility__c, Contact.Account.AIA_Master_Pricing_Schedule__c,accountid, Contact.Account.OwnerId,Contact.First_time_AIA__c,Contact.Account.AIA_MPS_Signing_Date__c,Contact.First_time_ASE__c,Contact.Account.AIA_Product__c from User limit 1 ];
        }
        isAIAProdChecked = currentLogged_User.Contact.Account.AIA_Product__c;
        isASEProdChecked = currentLogged_User.Contact.Account.ASE_Product__c;
        isAniraProdChecked = currentLogged_User.Contact.Account.Anira_Product__c;
        accID = currentLogged_User.accountid;
        isWirelessProduct = currentLogged_User.Contact.Account.Wireless_Product__c; 
        isTestAccount = currentLogged_User.Contact.Account.Test_Company__c;
        isMISChecked=currentLogged_User.Contact.Account.isMIS__c;
        isAVPNChecked=currentLogged_User.Contact.Account.isAVPN__c;
        
        System.debug('@@PS accID'+accID);
        AdminControl = [select id, AIA_MPS_Signing_Date__c, name from Admin_Control__c limit 1];
        if(currentLogged_User.id != null && currentLogged_User.contactId != null)
        {
            if(String.isNotBlank(currentLogged_User.Contact.Account.Product_Trainings_Completed__c) ){
                Prod_Code_Values = currentLogged_User.Contact.Account.Product_Trainings_Completed__c.split(SpecialCharacterConstant.SEMICOLON,0);
           }
            if(Test.isrunningTest()){
                Prod_Code_Values = new List<String>{BuyflowConstant.AVPN,BuyflowConstant.MIS,BuyflowConstant.ASE,BuyflowConstant.BROADBAND};
            }
            List<String> prodCodeRemoveList = new List<String>();
            for(String prodCode: Prod_Code_Values){
                if(prodCode == BuyflowConstant.MIS){
                    if (isMISChecked){
                        Prod_Code_Values.set(Prod_Code_Values.indexOf(prodCode),BuyflowConstant.AMIS);
                    }
                    else{     
                        prodCodeRemoveList.add(prodCode);
                    }
                }
                else if(prodCode == BuyflowConstant.ASE){
                   if (isASEProdChecked){
                       Prod_Code_Values.set(Prod_Code_Values.indexOf(prodCode),BuyflowConstant.ASE);
                   }   
                   else{     
                        prodCodeRemoveList.add(prodCode);
                   }
                }
                else if(prodCode == BuyflowConstant.AVPN){
                   if (!isAVPNChecked){
                        prodCodeRemoveList.add(prodCode);
                   }   
                }
                else  if(prodCode == BuyflowConstant.ANIRA){
                    if(isAniraProdChecked == false){
                        prodCodeRemoveList.add(prodCode);
                    }
                }
                if((prodCode.equalsIgnoreCase(BuyflowConstant.BROADBAND) || prodCode.equalsIgnoreCase(BuyflowConstant.AIA)))
                { 
                    if (isAIAProdChecked){
                        Prod_Code_Values.set(Prod_Code_Values.indexOf(prodCode),BuyflowConstant.AIA);
                    }else{       
                        prodCodeRemoveList.add(prodCode);
                    }
                }   
                if(prodCode == SIConstants.Attwireless){
                  if(!isWirelessProduct){
                        prodCodeRemoveList.add(prodCode);
                  }
                }                
            }
            if(prodCodeRemoveList.size()>0){
                for(String prodCodeToRemove: prodCodeRemoveList){
                    Prod_Code_Values.remove(Prod_Code_Values.indexOf(prodCodeToRemove));
                }
            }
        }
        
        if(CurrentLogged_User.Contact.Account.AIA_Consumer_Eligibility__c != null){
            if(CurrentLogged_User.Contact.Account.AIA_Consumer_Eligibility__c == True){
                aiacheckvalue = true;
            }
            else{
                aiacheckvalue = false;
            }
        }
        
        if(CurrentLogged_User.Contact.Account.AIA_Master_Pricing_Schedule__c != null){
            if(CurrentLogged_User.Contact.Account.AIA_Master_Pricing_Schedule__c == True){
                masterpricing = true;
            }
            else{
                masterpricing = false;
            }
        }
        
        if(CurrentLogged_User.id != null && CurrentLogged_User.contactId != null){
            if(!Test.isrunningTest()){
                userlist = [select id, EmailId__c, isActive from User Where Id=: CurrentLogged_User.Contact.Account.OwnerId];
            }
            else if(Test.isrunningTest()){
                    userlist = [select id, EmailId__c, isActive from User];
            }
            if(userlist[0].isActive == true){
                camaction = true; 
            }
            else{
                camaction = false;
            }

            if(userlist[0].EmailId__c != null && userlist[0].EmailId__c != SpecialCharacterConstant.CONCAT){
                camEmail = userlist[0].EmailId__c;
                CamAssigned = true;
                
            }
            else{
                CamAssigned = false;
            }
        }
        if(CurrentLogged_User.Contact.First_time_AIA__c != null ){
            if(CurrentLogged_User.Contact.First_time_AIA__c == false){
              FirstTimeUser = false;
            }
            else{
                FirstTimeUser = true;
            }
        }
     
        
        MPSAdminDateTime = AdminControl.AIA_MPS_Signing_Date__c;
        MPSAccountDateTime = CurrentLogged_User.Contact.Account.AIA_MPS_Signing_Date__c;
        
        if(MPSAdminDateTime != null){
            MPSAdminDate = MPSAdminDateTime;
        }
        
        if(MPSAccountDateTime != null){
            MPSAccountDate = MPSAccountDateTime;
        }
        
        
        if(CurrentLogged_User.Contact.Account.AIA_MPS_Signing_Date__c == null){
            MPSNotSigned = true;
        }
        else if(CurrentLogged_User.Contact.Account.AIA_MPS_Signing_Date__c == null && AdminControl.AIA_MPS_Signing_Date__c != null ){
            MPSNotSigned = true;
        }
        else if(CurrentLogged_User.Contact.Account.AIA_MPS_Signing_Date__c != null && AdminControl.AIA_MPS_Signing_Date__c == null ){
            MPSSigned = true;
        }
        else if(MPSAccountDate ==  MPSAdminDate){
            MPSSigned = true;
        }
        else if(MPSAccountDate > MPSAdminDate){
            MPSSigned = true;
        }
        else if(MPSAccountDate <  MPSAdminDate){
            MPSUpdated = true;
        }
          
        if(CurrentLogged_User.contactId== null){
            portaluserbool=false;
        }else{
            portaluserbool=true;
        }
        //Added by: Rk 11/27/2014
        productType = SpecialCharacterConstant.CONCAT;
        
        // Added by Anand 
        quoteId = apexpages.currentpage().getparameters().get('quoteid'); 
                
        if(CurrentLogged_User.Contact.First_time_ASE__c!= null ){                       
            if(CurrentLogged_User.Contact.First_time_ASE__c== true){
              FirstTimeUserASE = true;
            }
            else{
                FirstTimeUserASE = false;
            }
        }
       
    } 
    /*************************** Picklist for Term Section*******************************************************/
/* 
 Name: Termlist{
 Description: 
 */ 
    public  List<SelectOption> Termlist{
        
        get{
            
            if(Termlist== null){        
                    Termlist= new  List<SelectOption>();                     
                    // @Gavin 11/01/2014 Start: Put terms in the correct order
                    Termlist.add(new SelectOption(ATT_Constant.TERM_1YEAR,ATT_Constant.TERM_1YEAR));
                    // @Gavin 11/01/2014 End: Put terms in the correct order
                    Termlist.add(new SelectOption(ATT_Constant.TERM_3YEAR,ATT_Constant.TERM_3YEAR));
                    
            }    
       return Termlist;           
         
        }set;
    }
   
    
    // Picklist for AIA product radio button values
    
/* 
 Name: RadioButtonValues{
 Description: 
 */ 
    public  List<SelectOption> RadioButtonValues{
        
        get {
            if(RadioButtonValues == null){        
                RadioButtonValues = new  List<SelectOption>();                     
                RadioButtonValues.add(new SelectOption('Business','Business'));
                RadioButtonValues.add(new SelectOption('Consumer','Consumer'));
            }    
            return RadioButtonValues;           
        }set;
    }
    
/* 
 Name: EthernetOptionslist{
 Description: 
 */ 
    public  List<SelectOption> EthernetOptionslist{
        
        get{
            
            if(EthernetOptionslist== null){        
                    EthernetOptionslist= new  List<SelectOption>();                    
                    EthernetOptionslist.add(new SelectOption('Ethernet Private Line (Point-to-Point)','Ethernet Private Line (Point-to-Point)')); 
                    EthernetOptionslist.add(new SelectOption(BuyflowConstant.ETHERNETVIRTUAL_PRIVATE_LINE_HUB_AND_SPOKE_x,BuyflowConstant.ETHERNETVIRTUAL_PRIVATE_LINE_HUB_AND_SPOKE_x));
                    
            }    
       return EthernetOptionslist;           
        
        }set;
    }

/* 
 Name: TrafficJurisdictionOptionslist{
 Description: 
 */ 
    public  List<SelectOption> TrafficJurisdictionOptionslist{
        
        get{            
            if(TrafficJurisdictionOptionslist== null){        
                    TrafficJurisdictionOptionslist= new  List<SelectOption>();                    
                    TrafficJurisdictionOptionslist.add(new SelectOption('Interstate','Interstate')); 
                    TrafficJurisdictionOptionslist.add(new SelectOption('Intrastate','Intrastate'));                    
            }    
       return TrafficJurisdictionOptionslist;           
         
        }set;
    }
    
    
    // Changes to fix back button issue : 1/27 Start
    /*
     * Method name  : updateQuoteOnBack
     * Description  : This method is to update the quote on clicking back to persist user selection next time user comes to this page.
     * Return Type  : PageReference
     * Parameter    : None
     */ 

/* 
 Name: updateQuoteOnBack
 Description: 
 */ 
    public void updateQuoteOnBack(){  
try{    
        quoteObj.Apttus_QPConfig__PriceListId__c = null;
        quoteObj.Buyflow_Step__c=BuyflowConstant.ADDCUSTOMER;
        if(quoteName != null){
            quoteObj.Apttus_Proposal__Proposal_Name__c = quoteName;
        }
        if(selectedTerm != null && selectedTerm != SpecialCharacterConstant.CONCAT) {
            quoteObj.Apttus_Proposal__Payment_Term__c = selectedTerm;
        }
        if(aiaradiovalue != null && aiaradiovalue != SpecialCharacterConstant.CONCAT){
            if(quoteobj.Apttus_Proposal__Account__r.SAO_for_AIA__c == True && aiaradiovalue == BuyflowConstant.BUSINESS){
                quoteObj.AIA_Type__c = 'SAO Business';
            }
            else{
                 quoteObj.AIA_Type__c = aiaradiovalue;
            }
        }
        if(showProdAttr){
            if(!string.isempty(selectedEthernetconfiguration)){
                quoteObj.Ethernet_Configuration__c = selectedEthernetconfiguration;
            }else if(!string.isempty(apexpages.currentpage().getparameters().get('selectedEthernetconfiguration'))){
                quoteObj.Ethernet_Configuration__c =  apexpages.currentpage().getparameters().get('selectedEthernetconfiguration');
            }
            if(!string.isempty(selectedTrafficJurisdiction)){
                quoteObj.Traffic_Jurisdiction__c = selectedTrafficJurisdiction;
            }else if(!string.isempty(apexpages.currentpage().getparameters().get('selectTrafficJurisdiction'))){
                quoteObj.Traffic_Jurisdiction__c =  apexpages.currentpage().getparameters().get('selectTrafficJurisdiction');
            }
        }
         if(productId == null || productId == '') {
            productId = apexpages.currentpage().getparameters().get('productId');  
            system.debug('@@@^productId 1--'+productId);
        }
        if(productIdcheck== null || productIdcheck== SpecialCharacterConstant.CONCAT){
            quoteObj.Product__c = productId;
            system.debug('@@@^quoteObj.Product__c 2--'+quoteObj.Product__c);
        }
        else {
            quoteObj.Product__c = productIdcheck;        
        }
        try{
            update quoteObj;          
        }catch(Exception e) {
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }        
    }
          catch(Exception e){
    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
    }
    // Changes - End : 1/27
    
    //Start: Changes by RK
/* 
 Name: handleProductInfoPage
 Description: 
 */ 
    public void handleProductInfoPage() {
        try{ selectedTerm =  ATT_Constant.TERM_3YEAR;
            quoteId = apexpages.currentpage().getparameters().get('quoteId');
            if(quoteId != null) {
                 quoteObj = [select Name, Apttus_Proposal__Account__c, Apttus_Proposal__Account__r.SAO_for_AIA__c, End_Customer__c, End_Customer__r.Name, Apttus_Proposal__Proposal_Name__c,Product__c,Apttus_Proposal__Payment_Term__c,AIA_Type__c,Ethernet_Configuration__c,Traffic_Jurisdiction__c,Promotion_Simulation_Date__c from Apttus_Proposal__Proposal__c where id = :quoteId];                
                //if(quoteObj.Apttus_Proposal__Proposal_Name__c != null) {
                    quoteName = quoteObj.Apttus_Proposal__Proposal_Name__c;
                    tempQuoteName =quoteName ;
               // }
               selectedEthernetconfiguration = quoteObj.Ethernet_Configuration__c;  // back button issue add
               if(quoteObj.Traffic_Jurisdiction__c != null)
               selectedTrafficJurisdiction = quoteObj.Traffic_Jurisdiction__c; // back button issue add
               else
               selectedTrafficJurisdiction=BuyflowConstant.INTERSTATE;
                for(ProductWrapper wrapper : pWrapperList) {
                    if(wrapper.prodObj.Id == quoteObj.Product__c) {
                        wrapper.isSelected = false;
                        //break;
                    } else {
                        wrapper.isSelected = true;
                    }
                }


                // @Gavin 11/09/2014 Start: Setting the payment term if it is saved on the quote
                if(quoteObj.Apttus_Proposal__Payment_Term__c != null && quoteObj.Apttus_Proposal__Payment_Term__c != SpecialCharacterConstant.CONCAT) {
                    selectedTerm = quoteObj.Apttus_Proposal__Payment_Term__c;
                }
                
                if(quoteObj.AIA_Type__c != null && quoteObj.AIA_Type__c != SpecialCharacterConstant.CONCAT){
                    if(quoteObj.AIA_Type__c != 'SAO Business'){
                        aiaradiovalue = quoteObj.AIA_Type__c;
                    }
                    else{
                        aiaradiovalue = BuyflowConstant.BUSINESS;
                    }
                }
                
                // @Gavin 11/09/2014 End: Setting the payment term if it is saved on the quote
                //1/28 - Back button issue - Start
                    if(quoteObj.Product__c == null){
                        showProdAttr = false;
                    }
                //1/28 - End
            } else {
                quoteObj = new Apttus_Proposal__Proposal__c();
            }
      } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
       ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    //End: Changes by RK

    /* 
     Name: handleProductInfoRequest
     Description: This method insert a quote and display the product information.
     */ 
    public void handleProductInfoRequest(){
        try{  quoteId = apexpages.currentpage().getparameters().get('quoteId');
              if(quoteId != null) {
                quoteObj = [select Name,Account_Owner_Email__c, Apttus_Proposal__Account__r.owner.email, Apttus_Proposal__Opportunity__c, Apttus_Proposal__Opportunity__r.Name, Apttus_Proposal__Account__c, Apttus_Proposal__Account__r.SAO_for_AIA__c,End_Customer__c, End_Customer__r.Name, Apttus_Proposal__Proposal_Name__c,Product__c,Apttus_Proposal__Payment_Term__c,Ethernet_Configuration__c,Traffic_Jurisdiction__c,AIA_Type__c from Apttus_Proposal__Proposal__c where id = :quoteId];                
                if(quoteObj.Apttus_Proposal__Proposal_Name__c != null) {
                    quoteName = quoteObj.Apttus_Proposal__Proposal_Name__c;
                }
                
            } else {
                quoteObj = new Apttus_Proposal__Proposal__c();
            }
            // Apttus_Proposal__Proposal__c qObj = new Apttus_Proposal__Proposal__c();                      
            //Query to retrieve a product based on name. Filter ()
            if(portaluserbool){
            if (Prod_Code_Values != null && Prod_Code_Values.size() > 0) 
                for(Product2 p : [select id,Product_New_Name__c,name,Apttus_Config2__Icon__c,IsValid__c,Category__c,Sub_Product1__c,Sub_Product2__c,Productcode,IsActive,Apttus_Config2__IconId__c,Apttus_Config2__ConfigurationType__c from product2
                             where IsValid__c = true and Apttus_Config2__ConfigurationType__c =:ATT_Constant.CONFIG_TYPE AND Productcode IN: Prod_Code_Values AND Productcode NOT IN: Prod_Code_To_Exclude_Values and IsActive = true order by Sequence__c]){                     
                    pWrapperList.add(new ProductWrapper(p,false));
            }
            }
            else{
            system.debug('else part' + Prod_Code_To_Exclude_Values);
            for(Product2 p : [select id,Product_New_Name__c,name,Apttus_Config2__Icon__c,IsValid__c,Category__c,Sub_Product1__c,Sub_Product2__c,Productcode,IsActive,Apttus_Config2__IconId__c,Apttus_Config2__ConfigurationType__c from product2
                             where IsValid__c = true and Apttus_Config2__ConfigurationType__c =:ATT_Constant.CONFIG_TYPE AND Productcode NOT IN: Prod_Code_To_Exclude_Values and IsActive= true order by Sequence__c /*AND Productcode IN: Prod_Code_Values*/]){                     
                    pWrapperList.add(new ProductWrapper(p,false));
                    }
            }        
             
            for(ProductWrapper wrapper : pWrapperList) {
                    if(wrapper.prodObj.Id == quoteObj.Product__c) {
                        wrapper.isSelected = false;
                        //break;
                    } else {
                        wrapper.isSelected = true;
                    }
                }

            // @Gavin 11/09/2014 Start: Setting the payment term if it is saved on the quote
            if(quoteObj.Apttus_Proposal__Payment_Term__c != null && quoteObj.Apttus_Proposal__Payment_Term__c != SpecialCharacterConstant.CONCAT) {
                selectedTerm = quoteObj.Apttus_Proposal__Payment_Term__c;
            }
            
            if(quoteObj.AIA_Type__c != null && quoteObj.AIA_Type__c != SpecialCharacterConstant.CONCAT){
               if(quoteObj.AIA_Type__c != 'SAO Business'){
                        aiaradiovalue = quoteObj.AIA_Type__c;
                    }
                    else{
                        aiaradiovalue = BuyflowConstant.BUSINESS;
                    }
            }
            
            //@Prem 11/11/2014 added for checking "Approve For Mobility" checkbox
            Account obj= new Account();
            if(obj.Approved_for_Mobility__c==true){   //obj.Approved_for_Mobility__c==false
                checkMobilityFlag=true; 
                // for now , all account have Approved_for_Mobility__c as SpecialCharacterConstant.FALSE_LITERAL
            }else{
                 checkMobilityFlag=false;
            }
           } catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
        ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
/* 
 Name: updateConfigAndJurisdiction
 Description: 
 */ 
     public void updateConfigAndJurisdiction(){
         try{
        if(quoteId == null || quoteId == ''){ 
            quoteId = apexpages.currentpage().getparameters().get('quoteId');
        }
        if(productId == null || productId == '') {
                productId = apexpages.currentpage().getparameters().get('productId');      
        }
        Apttus_Proposal__Proposal__c quoteASE = new Apttus_Proposal__Proposal__c();
        quoteASE.Id = quoteId;
        quoteASE.product__c = productId;
        if(!string.isempty(selectedEthernetconfiguration)){
            quoteASE.Ethernet_Configuration__c = selectedEthernetconfiguration;
        }else if(!string.isempty(apexpages.currentpage().getparameters().get('selectedEthernetconfiguration'))){
            quoteASE.Ethernet_Configuration__c =  apexpages.currentpage().getparameters().get('selectedEthernetconfiguration');
        }
        if(!string.isempty(selectedTrafficJurisdiction)){
            quoteASE.Traffic_Jurisdiction__c = selectedTrafficJurisdiction;
        }else if(!string.isempty(apexpages.currentpage().getparameters().get('selectTrafficJurisdiction'))){
            quoteASE.Traffic_Jurisdiction__c =  apexpages.currentpage().getparameters().get('selectTrafficJurisdiction');
        }
        update quoteASE;
       
    }
          catch(Exception e){
    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
     }
     /*
     * Method name  : updateQuote
     * Description  : This method update the quote .
     * Return Type  : PageReference
     * Parameter    : None
     */ 
    
/* 
 Name: updateQuote
 Description: 
 */ 
    public pageReference updateQuote(){
        try{
            PageReference retPageRef;
            Product2 productObj  = null;
            product2 prod;
            try{             
                if(productId == null || productId == '') {
                    productId = apexpages.currentpage().getparameters().get('productId');  
                    system.debug('@@@^productId 4--'+productId);
                }
                
                if(productId!=null && !string.isBlank(productId)) {
                    prod = [select productCode,Name from product2 where id =:productId];
                    productNamecheck = prod.Name;
                    system.debug('@@@^productNamecheck 5--'+productNamecheck);
                }
                
                quoteObj.Apttus_Proposal__Proposal_Name__c = quoteName;
                if(PromotionSimulationDate!=null){
                    quoteObj.Promotion_Simulation_Date__c = PromotionSimulationDate;
                }
                if(productIdcheck== null || productIdcheck== SpecialCharacterConstant.CONCAT){
                    quoteObj.Product__c = productId;
                    system.debug('@@@^quoteObj.Product__c 6--'+quoteObj.Product__c);
                }else{ 
                    quoteObj.Product__c = productIdcheck; 
                    system.debug('@@@^quoteObj.Product__c else--'+quoteObj.Product__c);
                }
                    
                quoteObj.Apttus_Proposal__Payment_Term__c=selectedTerm ;
                if(aiaradiovalue != null && aiaradiovalue != SpecialCharacterConstant.CONCAT){
                    if(prod.ProductCode=='AIA')   { 
                        if(quoteobj.Apttus_Proposal__Account__r.SAO_for_AIA__c == True && aiaradiovalue == BuyflowConstant.BUSINESS){
                            quoteObj.AIA_Type__c = 'SAO Business';
                        }
                        else{
                            quoteObj.AIA_Type__c = aiaradiovalue;
                         }
                    }
                }
                  
                if(quoteObj.Product__c != null){
                    productObj = [select id, ProductCode, Name, Family from Product2 where id = :quoteObj.Product__c]; 
                    if(productObj.ProductCode ==BuyflowConstant.AVPN|| productObj.ProductCode==BuyflowConstant.AMIS){
                         quoteObj.Buyflow_Step__c=BuyflowConstant.ADDSITES;
                    }
                                    
                    if(quoteObj.Id != null) {                    
                        if(!String.isBlank(productNamecheck) && ((productNamecheck.contains('RingCentral'))||(productNamecheck.contains('Jasper')))){
                            if(quoteObj.Name!=null){
                                quoteName=quoteObj.Name;
                            }
                            MobileServiceUtility helper2 = new MobileServiceUtility();
                            helper2.ApttusHelper(quoteObj.Product__c,quoteName,null);
                        }
                      
                        if(productObj.ProductCode == BuyflowConstant.ANIRA) {
                            quoteObj.Buyflow_Step__c= BuyflowConstant.CONFIGURESITES;
                            if(quoteName==SpecialCharacterConstant.CONCAT){
                                quoteObj.Apttus_Proposal__Proposal_Name__c=quoteObj.Name;
                            }else{
                                quoteObj.Apttus_Proposal__Proposal_Name__c = quoteName;
                            }                      
                            productType = BuyflowConstant.ANIRA;                            
                            //Fix for defect 34097
                            quoteObj.AIA_Type__c=SpecialCharacterConstant.CONCAT;
                            quoteObj.RDS_Site_Status__c=SpecialCharacterConstant.CONCAT;                        
                        }else {
                            retPageRef = null;
                        }
                        
                        if(quoteName==SpecialCharacterConstant.CONCAT) {
                            quoteObj.Apttus_Proposal__Proposal_Name__c=quoteObj.Name;
                        }
                        
                        if(prod.ProductCode != BuyflowConstant.ANIRA && prod.ProductCode!='Attwireless'){                      
                            quoteObj.Buyflow_Step__c=BuyflowConstant.ADDSITES;                      
                        }
                        
                        list<Account> aList = [select id,owner.email from Account where id =: quoteObj.Apttus_Proposal__Account__c];
                        system.debug('FFFFFFFFFFFFFFFFFFFFF' + aList[0].owner.email);
                        quoteObj.Account_Owner_Email__c = aList[0].owner.email;
                        update quoteObj;
                    }
                    quoteid = quoteObj.id; 
                }          
            }catch(Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            }
            
            /*** Start - Fix for ORT defect 279761 ***/
            if(quoteObj.id == null){
                if(quoteObj.Name!=null){
                    Apttus_Proposal__Proposal__c quoteObject1 = new Apttus_Proposal__Proposal__c();
                    quoteObject1 = [select id from Apttus_Proposal__Proposal__c where Name = :quoteObj.Name];
                    quoteObj.id = quoteObject1.id;
                }
            }                       
                       
            if(quoteObj.id == null){           
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,BuyflowConstant.NAVIGATION_ERROR));
                return null;
            }else{
                if(productObj.ProductCode == BuyflowConstant.ANIRA) {
                    retPageRef = Page.ANIRA_Buyflow;
                    retPageRef.getParameters().put('quoteid', quoteObj.id);                       
                }else if(productObj.ProductCode == BuyflowConstant.AVPN || productObj.ProductCode == BuyflowConstant.AMIS || productObj.ProductCode == BuyflowConstant.ASE){
                    retPageRef = Page.Buyflow;            
                    retPageRef.getParameters().put('mode', 'siteinfo');
                    retPageRef.getParameters().put('quoteid', quoteObj.id);
                }
                return retPageRef;
            }
            /*** End - Fix for ORT defect 279761 ***/                                                   
        }         
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            return null;
        }
    } 
    /* 
     Name: populateQuoteName
     Description: 
     */ 
    public void populateQuoteName(){    
        try{ 
            system.debug('@@@^productId before 121---'+productId);
            productId = apexpages.currentpage().getparameters().get('productId');
            system.debug('@@@^productId 1231323---'+productId);
          
        }catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
       ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }       
    }
    
    /* 
     Name: renderprodAttr
     Description: 
     */ 
    public pageReference renderprodAttr()
    {   
        set<String> termSet = new set<String>();
        list<string>termSetList= new list<String>();
        try{
            productId1 = apexpages.currentpage().getparameters().get('productId1');
            productId = productId1;
            Termlist.clear();
            system.debug('@@@^PS productId1  '+productId1 );
            system.debug('@@@^ productId 8--- '+productId );
            if(productId1.contains(Label.ASE_Product_Id)  )
            {
               // showProdAttr = true;
                termSet=updateASETerm();
                termSetList.addAll(termSet);
                termSetList.sort();
                if(termSet.size()>0)
                    {
                       
                        for( String tr: termSetList)
                        {
                        Termlist.add(new SelectOption(tr,tr));  
                        }
                    }
                    
                    system.debug('@@Ps Termlist: '+Termlist);
            }
            else
            {
                //showProdAttr = false;
                Termlist.add(new SelectOption(ATT_Constant.TERM_1YEAR,ATT_Constant.TERM_1YEAR));
                    
                Termlist.add(new SelectOption(ATT_Constant.TERM_3YEAR,ATT_Constant.TERM_3YEAR));
                
            }      
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }       
        return null;
    }
    //Changed by SK (Refer defect no : DE85094)
    
    /* 
     Name: cancel
     Description: 
     */ 
    public pageReference cancel(){
        try{
            if(quoteId !=null){
                quoteObj.Apttus_Proposal__Approval_Stage__c = ATT_Constant.DELETED;
                update quoteObj;
                PageReference qDashBoard = system.page.PortalDashboard_UI;//QuotesAndOrdersDashboard_UI;              
                return qDashBoard ;
            }
            else{
                return null;
            }           
        }catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
        ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        return null;
        }
        
    }
    
    /* 
     Name: ProductWrapper
     Type: Class 
     Description: 
     */ 
    public class ProductWrapper {
    
        public Product2 prodObj{get;set;}
        public Boolean isSelected{get;set;}
        /* 
         Name: ProductWrapper
         Description: Constructor
         */ 
        public ProductWrapper(Product2 prodObj,Boolean isSelected)
        {
            this.prodObj=prodObj;
            this.isSelected=isSelected;
        }
        
    }
    /*************
    Created by chanda Dipendu for updating pop values in Product Attribute
    *************/
    
    //-----
       public string flag {get;set;}
/* 
 Name: selectEndCustomerFan
 Description: 
 */ 
    public void selectEndCustomerFan(){
        try{
        flag = BuyflowConstant.SIVARConst_1;
        MobileServiceUtility helper = new MobileServiceUtility();
        if(productIdcheck!=null){
            productId=productIdcheck;
        }
        if(quoteObj.Name!=null){
            quoteName=quoteObj.Name; 
        }
        //helper.ApttusHelper(productId,quoteName,typeOfFan);
            
    } 
      catch(Exception e){
    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
    }   
/* 
 Name: selectConsumerForUseFan
 Description: 
 */ 
    public void selectConsumerForUseFan(){
        try{
        flag = BuyflowConstant.SIVARConst_0;
        MobileServiceUtility helper = new MobileServiceUtility();
        if(productIdcheck!=null){
            productId=productIdcheck;
        }
        if(quoteObj.Name!=null){
            quoteName=quoteObj.Name; 
        }
            // helper.ApttusHelper(productId,quoteName,typeOfFan);
            
    }
           catch(Exception e){
    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
    }
    //----
/* 
 Name: selectFan
 Description: 
 */ 
    public void selectFan(){    
try{    
        MobileServiceUtility helper = new MobileServiceUtility();
        if(productIdcheck!=null){
            productId=productIdcheck;
        }
        if(quoteObj.Name!=null){
            quoteName=quoteObj.Name;
        }           
        //helper.ApttusHelper(productId,quoteName,typeOfFan);
            
    }      
      catch(Exception e){
    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
    }   
    /*********************************************
    * Method name : setErrorMessage
    * Description : sets error Meassage
    * Return Type : void
    * Parameter : None
    *********************************************/
    
/* 
 Name: setErrorMessage
 Description: 
 */ 
    public void setErrorMessage(){
        try{
        ErrorMessage = null;
    } 
          catch(Exception e){
    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
    }
      /*
     * Method name  : callLoginDispatchService
     * Description  : This method calls the service and return the url for the product information.
     * Return Type  : String
     * Parameter    : None
     */ 
/* 
 Name: callLoginDispatchService
 Description: 
 */ 
      public void callLoginDispatchService(){
        try{
        }catch(Exception e){
          ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
      }
/* 
 Name: callLoginDispatchServicePI
 Description: 
 */ 
    public void callLoginDispatchServicePI(){
        String encryptedString=null;
        List<Map<String,String>> requestBeanList=null;
        try{             
          User usr = new User();
            usr = [Select Id,Name,ContactId FROM User WHERE id=:userinfo.getuserId()];
            
            Contact cont = new Contact();
            if(usr.ContactId != null) {  
                cont = [SELECT Id, Name, AccountId,Account.Name, Premier_Login__c FROM Contact WHERE Id=:usr.ContactId];
               
            }
            
            Apex2JSON_LoginDispatchRequest requestBean = new Apex2JSON_LoginDispatchRequest();
            LoginDispatchService objService= new LoginDispatchService();
                    Apttus_Proposal__Proposal__c quoteObject = new Apttus_Proposal__Proposal__c();
                    //quoteId = apexpages.currentpage().getparameters().get('quoteId');
                    quoteId=quoteNo;
                   // quoteId =BuyflowConstant.Q00002908;
                    //if(quoteId != null) {
                    if(quoteObj.Name!=null){
                        quoteObject = [select id,Name, Premier_Order_ID__c,End_Customer__c, End_Customer__r.Name, Apttus_Proposal__Account__r.Current_Tier__c,Apttus_Proposal__Account__r.Premier_Login__c from Apttus_Proposal__Proposal__c where Name = :quoteObj.Name];           
                        List<String> qouteOb = new List<String>();
                        qouteOb.add(quoteObject.End_Customer__r.Name);
                        qouteOb.add(quoteObject.Apttus_Proposal__Account__r.Current_Tier__c);
                        
                        requestBeanList= new List<Map<String,String>>();
                        Map<String,String> mapObj= new Map<String,String>();
                        
                        //mapObj.put('ProvisioningServiceID',quoteObject.id); //a2xm00000008ZC3AAM
                        mapObj.put('ProvisioningServiceID',quoteObject.Name);
                        //mapObj.put('ProvisioningServiceID','o32257000055');
                        mapObj.put('SourceSystemUserID',quoteObject.End_Customer__r.Name);
                        mapObj.put('ProfileType',(!string.isBlank(quoteObject.Apttus_Proposal__Account__r.Current_Tier__c)?quoteObject.Apttus_Proposal__Account__r.Current_Tier__c.toUpperCase():''));                                                
                        //mapObj.put('PremierLogin',(!string.isBlank(quoteObject.Apttus_Proposal__Account__r.Premier_Login__c)?quoteObject.Apttus_Proposal__Account__r.Premier_Login__c:'')); 
                        mapObj.put('PremierLogin',(!string.isBlank(cont.Premier_Login__c)?cont.Premier_Login__c:'')); 
                        //mapObj.put('PremierLogin','QAPEMobilityTCM1508');
                        mapObj.put('PremierOrderId',(!string.isBlank(quoteObject.Premier_Order_ID__c)?quoteObject.Premier_Order_ID__c:''));
                        //mapObj.put('PremierOrderId','10101241459214425');
                        mapObj.put('Dealdiscount','');
                        mapObj.put('PremierUserStatus','');
                        mapObj.put('PEDealStatus','');
                        
                        requestBeanList.add(mapObj);
                    }
                    requestBean = objService.populateRequestBean(requestBeanList); 
                    
            
           // requestBean = objService.populateRequestBean();       
            Apex2JSON_LoginDispatchResponse responseBean = new Apex2JSON_LoginDispatchResponse();
            String strTemp = '{"LoginDispatchResponse": {"WSResponseHeader": null,"Header": {"sourceSystem": "EBM","sourceServerDomain": "ST","transactionID": "1413313506665"},"LoginDispatch": {"TokenURL": "C5j45mSEdqfz4f4GnrwR2T25tizY5gb3JoVNtWp8DiYOW5d+qvPx/ODmQIQqNXpZ1YkIjLwu5BAjDh3QmlrC4DKwTvbSrVqxh7OJdGDQy61pY0V/p3JINnSHoA3V59y8PyEKzw0ipJYRx7aH4P45A54fHUeYAPmhl7eJfTknjgvK3gInuom2gAc05rEGSSNfrWNXFcr7/OozXbrO2lDposIo1aWyIGxHHPbH1HDxrXGv6QKkir068oPZ4JYvmwvml9MLyBajtQ6FzExrjz+iWyEpyAIGMY920/wNhfDv9Qy6wU2my048Od2Cp5l7aPvg","Response": {"code": "200","description": "SUCCESS"}}}}';
            if(Test.isrunningTest()){
                responseBean  = (Apex2JSON_LoginDispatchResponse)JSON.deserialize(strTemp, Apex2JSON_LoginDispatchResponse.class);
            }
            if(!Test.isrunningTest())  {              
                responseBean  = (Apex2JSON_LoginDispatchResponse)objService.handleLoginDispatchService(requestBean);
            }
            if(responseBean!=null&& responseBean.LoginDispatchResponse!=null &&
            responseBean.LoginDispatchResponse.LoginDispatch!=null &&
            responseBean.LoginDispatchResponse.LoginDispatch.response!=null) {
                if(!responseBean.LoginDispatchResponse.LoginDispatch.response.code.equals('200') &&
                responseBean.LoginDispatchResponse.LoginDispatch.response.description!=null &&
                responseBean.LoginDispatchResponse.LoginDispatch.TokenURL == null) {
                    ErrorMessage = (!string.isBlank(responseBean.LoginDispatchResponse.LoginDispatch.response.description))?responseBean.LoginDispatchResponse.LoginDispatch.response.description:'';
                    encryptedUrl = '';
                    deEncryptedUrl = '';                                       
                    return;
                }else if(responseBean.LoginDispatchResponse.LoginDispatch.response.code.equals('200') &&
                !String.isBlank(responseBean.LoginDispatchResponse.LoginDispatch.TokenURL)){
                    encryptedString=responseBean.LoginDispatchResponse.LoginDispatch.TokenURL;               
                   Blob encryptedUrl1 = EncodingUtil.base64Decode(encryptedString);
                   ATnT_Encrypt_LD__c base64Key = ATnT_Encrypt_LD__c.getInstance();
                   Blob key = EncodingUtil.base64Decode(base64Key.Encrypted_Key_Value__c);
                   Blob deEncryptedUrlB = Crypto.decryptWithManagedIV('AES256', key, encryptedUrl1);
                   deEncryptedUrl = deEncryptedUrlB.toString();
                    
                }
                else
                {
                ErrorMessage = 'Premier is unavailable. Please try again later.';
                encryptedUrl = ''; 
                deEncryptedUrl = '';
                                   
                }
            }else {
                ErrorMessage = 'Premier is unavailable. Please try again later.';
                encryptedUrl = '';
                deEncryptedUrl = '';                
                return;
            }
         } catch(Exception e){
                         ErrorMessage = 'Premier is unavailable. Please try again later.';
                encryptedUrl = '';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        encryptedUrl=encryptedString;
    }    
    
/* 
 Name: changeIPFlexFlag
 Description: 
 */ 
    public void changeIPFlexFlag(){
        try{
        ipflexSelected= true;
        ipflexSelected1=ipflexSelected;
    }
          catch(Exception e){
    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
    }
    /* 
     Name: checkForPremierUpdate
     Description: 
     */ 
    public void checkForPremierUpdate()
    {
        try{
        String strQuoteId = System.currentPageReference().getParameters().get('quotID');
        if(quoteObj != null)
        {
            strQuoteId = quoteObj.Id;   
        }
        Apttus_Proposal__Proposal__c copyQuoteObj = [Select Id,Apttus_Proposal__Approval_Stage__c,Premier_Order_Id__c from Apttus_Proposal__Proposal__c where Id = :quoteObj.Id];
        if(copyQuoteObj.Premier_Order_Id__c == null || copyQuoteObj.Premier_Order_Id__c ==SpecialCharacterConstant.CONCAT)
        {
            quoteObj.Apttus_Proposal__Approval_Stage__c =BuyflowConstant.DELETED; 
            
        }
        update quoteObj;
    }
          catch(Exception e){
    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
    }
/* 
 Name: selectDeEncrypted
 Description: 
 */ 
    public void selectDeEncrypted(){
        try{
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
/* 
 Name: enableWirelessRadio
 Description: 
 */ 
     public void enableWirelessRadio(Id contId){
         try{
        Contact cont = [select account.Wireless_Product__c  from contact where id =: contId];
        if(cont.account.Wireless_Product__c){
             checkWirelessFlag = true;
        }
        else {checkWirelessFlag = false;}
    
        }
          catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
     }
     
    /* 
     Name: updateusersAIA
     Description: 
     */ 
    public void updateusersAIA(){
        try{
        User current_User=[select id, Contact.Account.Product_Trainings_Completed__c, Contact.Account.AIA_Consumer_Eligibility__c, Contact.Account.AIA_Master_Pricing_Schedule__c, Contact.Account.OwnerId,Contact.First_time_AIA__c from User Where Id=: UserInfo.getUserId()];
        Contact current_Contact = [select id ,First_time_AIA__c  from Contact where ID =: current_User.contactId];
        current_Contact.First_time_AIA__c = false;
        update current_Contact;
        FirstTimeUser = false;
    }
          catch(Exception e){
    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
    }
    
    /* 
     Name: updateQuoteAIA
     Description: 
     */ 
    public pageReference updateQuoteAIA(){
        PageReference retPageRef;
        try{
            product2 prod = [select Name,ProductCode from product2 where ProductCode ='AIA'];
            
            if(prod != null ){
                quoteObj.Product__c = prod.id;  
            }   
            quoteObj.Apttus_Proposal__Payment_Term__c=selectedTerm ;
            if(aiaradiovalue != null && aiaradiovalue != SpecialCharacterConstant.CONCAT){
                if(quoteobj.Apttus_Proposal__Account__r.SAO_for_AIA__c == True && aiaradiovalue == BuyflowConstant.BUSINESS){
                     quoteObj.AIA_Type__c = 'SAO Business';
                }
                else{
                    quoteObj.AIA_Type__c = aiaradiovalue;
                    }
            }            
            if(quoteObj.Product__c != null){
                if(quoteObj.Id != null) {
                    if(quoteName==SpecialCharacterConstant.CONCAT){
                        quoteObj.Apttus_Proposal__Proposal_Name__c=quoteObj.Name;
                    } else  {
                        quoteObj.Apttus_Proposal__Proposal_Name__c = quoteName;
                    }
                    quoteObj.Buyflow_Step__c=BuyflowConstant.ADDSITES;
                    update quoteObj;
                }
                quoteid = quoteObj.id; 
            }          
        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        
        /*** Start - Fix for ORT defect 279761 ***/
        if(quoteObj.id == null){
            if(quoteObj.Name!=null){
                Apttus_Proposal__Proposal__c quoteObject2 = new Apttus_Proposal__Proposal__c();
                quoteObject2 = [select id from Apttus_Proposal__Proposal__c where Name = :quoteObj.Name];
                quoteObj.id = quoteObject2.id;
            }
        }
        
        if(quoteObj.id == null){           
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,BuyflowConstant.NAVIGATION_ERROR));
            return null;
        }else{
            retPageRef = Page.AIA_canvasDisplayPage;
            retPageRef.getParameters().put('quoteid', quoteObj.id); 
            return retPageRef;
        }
        /*** End - Fix for ORT defect 279761 ***/                
    }
    
    /*updateASETerm*/
     public set<String> updateASETerm() { 
     try{
        list<ASE_Wholesale_Contract_Number__c> aseList= new list<ASE_Wholesale_Contract_Number__c>();
        set<String> Term = new set<String>();  
        System.debug('@@PS accID '+accID);
        if(accID!=null){
        aseList= [SELECT id,Term__c, Account_Name__c FROM ASE_Wholesale_Contract_Number__c where Account_Name__c=: accID and Active__c=true ];
         System.debug('@@PS aseList'+aseList);
         if(aseList!=null && aseList.size()>0){
                for (ASE_Wholesale_Contract_Number__c ase: aseList ) {
                            String[] regions = ase.Term__c.split(';');
                            for( String st: regions)
                            {
                                Term.add(st);
                            }
                 }
          }
         system.debug(Term);
         return Term;
      }
      else
       return null;
          }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                return null;
            }
     }
     
     /*updateusersASE*/
     public void updateusersASE(){
        try{
        User current_User=[select id, Contact.Account.Product_Trainings_Completed__c, Contact.Account.AIA_Consumer_Eligibility__c, Contact.Account.AIA_Master_Pricing_Schedule__c, Contact.Account.OwnerId,Contact.First_time_AIA__c from User Where Id=: UserInfo.getUserId()];
        Contact current_Contact = [select id ,First_time_ASE__c from Contact where ID =: current_User.contactId];
        current_Contact.First_time_ASE__c  = true;
        update current_Contact;
        FirstTimeUser = true;
    }
          catch(Exception e){
    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
 }
 }
     
}