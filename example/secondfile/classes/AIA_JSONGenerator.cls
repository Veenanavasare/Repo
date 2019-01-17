/**********************************************************
Apex Class to Generate JSON for the Quote/Proposal record
and log parameters being sent to Canvas.See object Canvas 
Debug Log Control Object for Parameter logging
**********************************************************/
public class AIA_JSONGenerator{
    public string recordId{get; set;}
    public String jsonContent {get; set;}
    public String timeOutValue  {get; set;}
    public String canvasHeight{get; set;}
    public String canvasWidth{get; set;}
    public list<Apttus_Proposal__Proposal__c> proposalObj = new list<Apttus_Proposal__Proposal__c>();
    
    public AIA_JSONGenerator(ApexPages.StandardController controller) {
        //To fetch Quote Id from the URL
        recordId = ApexPages.currentPage().getParameters().get('quoteId');
       // getJSONContent();    
    }
    //Method to generate JSON 
    public void getJSONContent() {
        //Query to fetch fields from the Proposal Object for generating JSON 
        
        proposalObj = [select id, name, Product_Name__c,Apttus_Proposal__Proposal_Name__c from Apttus_Proposal__Proposal__c where id=:recordId limit 1];
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('Record Id ', proposalObj[0].id );
        gen.writeStringField('Proposal ID ', proposalObj[0].name );
        if(proposalObj[0].Apttus_Proposal__Proposal_Name__c != null && proposalObj[0].Apttus_Proposal__Proposal_Name__c != '') {
          gen.writeStringField('Proposal Name ', proposalObj[0].Apttus_Proposal__Proposal_Name__c );
        } else {
          gen.writeStringField('Proposal Name ', proposalObj[0].name );
        }        
        
        if(canvasHeight != null && canvasHeight !=''){
            gen.writeStringField('height ', canvasHeight );
        }
        if(canvasWidth != null && canvasWidth !=''){
            gen.writeStringField('width ', canvasWidth );
        }
        gen.writeEndObject();
        jsonContent = gen.getAsString();
        system.debug('This is the generated JSON : ' + jsonContent);
    }
    
    /************************************************************************************
    * Method : logCanvasParameters()
    * Return type :  void
    * Logic: To log the parameters in custom object "Canvas Debug Log Control". Logic is 
    *        controlled by custom setting as a switch.
    *************************************************************************************/
    public void logCanvasParameters(){
        getJSONContent();
        //Custom Setting to enable / disable parameter logging feature
        Canvas_Debug_Log_Control__c cdlcObj = Canvas_Debug_Log_Control__c.getvalues('Canvas Parameter Logging');
        boolean enableParameterLog = cdlcObj.Enable_Parameter_Logging__c;
        timeOutValue = cdlcObj.TimeOut_Value__c;
        if(enableParameterLog){
            list<Canvas_Debug_log__c> cdlList = new list<Canvas_Debug_log__c>();
          //  proposalObj = [select id, name, Apttus_Proposal__Proposal_Name__c from Apttus_Proposal__Proposal__c where id=:recordId limit 1];
            system.debug('This is the Proposal fetched: ' + proposalObj);
            Canvas_Debug_log__c cdlObj = new Canvas_Debug_log__c();
            cdlObj.Quote_Id__c = proposalObj[0].id;
            cdlObj.Quote_Name__c = proposalObj[0].Apttus_Proposal__Proposal_Name__c;
            cdlObj.User_Name__c = userInfo.getUserId();
            if(proposalObj[0].Product_Name__c != null)
            cdlObj.Product_Type__c = proposalObj[0].Product_Name__c;
            cdlList.add(cdlObj);
            if(!cdlList.isEmpty()){
                try{
                    database.insert(cdlList);
                } Catch (DmlException e){
                    system.debug('Failed to insert the Parameters' + e);
                }
            }
        }
    }
    
   /************************************************************************************
    * Method : clearDiscount()
    * Return type :  void
    * Logic:  
    * 1.Opportunity Status changes to  'Saved'
    * 2.clear's discounts for ANIRA When clicked on reconfigured 
    *************************************************************************************/
     @RemoteAction
      public Static void clearDiscount(String recordId){
        try{
            
            
            Apttus_Proposal__Proposal__c objProposal= [Select Id,Apttus_Proposal__Approval_Stage__c,Name,Apttus_Proposal__Proposal_Name__c,Apttus_Proposal__Opportunity__c,Apttus_Proposal__Opportunity__r.Opportunity_ID__c, Apttus_Proposal__Account__c,Apttus_Proposal__Account__r.Name from Apttus_Proposal__Proposal__c where id=:recordId];    
           system.debug('!!!objProposal: '+objProposal);
           system.debug('!!!objProposal: '+objProposal.id);
           
            //Update Opportunity
            
          Opportunity objOpp= [Select Id,Name,StageName,Discounted_Percentage__c, Custom_Deal_Reg_Percentage__c, Discounted_Price__c, Calculated_Discount_Percentage__c, Discount_Amount__c, Cumulative_OTC_Discount_Price__c from Opportunity where id=:objProposal.Apttus_Proposal__Opportunity__c Limit 2];
            system.debug('######objOpp  before : '+objOpp);
            
            objOpp.stageName = 'Saved';
            objOpp.Custom_Deal_Reg_Percentage__c =0;
            objOpp.Discounted_Price__c =0;
            objOpp.Calculated_Discount_Percentage__c = 0;
            objOpp.Cumulative_OTC_Discount_Price__c = 0;
            objOpp.Discounted_Percentage__c = 0.00;
            objOpp.Discount_Amount__c = 0;
            objOpp.Quote_Expiration_Date__c = null;
            objOpp.Deal_Reg_Approval_Date__c = null;
            
            update objOpp;
            system.debug('######lstSPProduct after : '+objOpp);
            system.debug('####objOppLst.id'+objOpp.id);

            //Update SPProduct
            List<spProduct__C> lstSPProduct = [Select id,Deal__c,Discounted_Price__c, One_Time_Revenue_Discount_Price__c FROM spProduct__C WHERE Deal__c = :objOpp.id];
            system.debug('######lstSPProduct before : '+lstSPProduct);
            system.debug('####objOppLst.id'+objOpp.id);
            
            for(spProduct__C objSPP : lstSPProduct){
                objSPP.Discounted_Price__c =0;
                objSPP.One_Time_Revenue_Discount_Price__c = 0;
            }
            if(!lstSPProduct.isEmpty()) update lstSPProduct;
            system.debug('#######lstSPProduct after : '+lstSPProduct);
            
            //Product Pricing
            List<Product_Pricing__c> lstPP = [Select id, SP_Discount_Percentage__c, discounted_price__c,discount_price__c FROM Product_Pricing__c WHERE SP_Product__c =: lstSPProduct];
            system.debug('######lstPP before : '+lstPP);
            for(Product_Pricing__c objPP : lstPP){
                objPP.SP_Discount_Percentage__c =0;
                objPP.discounted_price__c = 0;
                objPP.discount_price__c=0;
            }
            if(!lstPP.isEmpty()) update lstPP;
            system.debug('#######lstPP after : '+lstPP);
            
            
        
        }catch(Exception ae){
            System.debug('**** Exception occured ' + ae.getMessage());
        }
        
    }   
 
}