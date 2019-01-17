/*
   **************************************************************************************************************         
               Component Name : SIProductPricingTriggerHandler 
               Component Description: All Product Pricing Related methods and exceution can be called from this Handeler. A generic trigger handler class for all the 
                                      operations(Insert,Update,Delete and Undelete) which operates on 'Before/After'     
               Author Name : Accenture IDC    
               Version:1.0    
               Created Date:12th Jan  2013     
               Last Modified Date:12th Dec 2014      
               Description: Code Refactoring and Condition Check for API Methods/SOQL    
               Last Modified Date:2nd Dec 2014      
               Description: Code Optimzation and  Addition of Constant Static for Hard Coded Values 
               Last Modified Date : 12th Dec 2014  
               Description : Addition of Constant Static for Hard Coded Values  
                    
     ****************************************************************************************************************
     */
public with sharing class SIProductPricingTriggerHandler extends SITriggerOperations.SITriggerImpl {
    
    public boolean isExecuted ;
    public boolean isNRC {set;get;}
    public boolean isNoneNRC = false;

    //Default cons
/* 
 Name: SIProductPricingTriggerHandler
 Description: 
 */ 
    public SIProductPricingTriggerHandler() {
        isExecuted = true;
    }
    
    //An Overridden method
/* 
 Name: onBeforeInsert
 Description: 
 */ 
    public override boolean onBeforeInsert(SObject[] newObjects) {
        
      List<Product_Pricing__c> ppList = newObjects;
        List<Product_Pricing__c> pprcList = new List<Product_Pricing__c>();
        for(Product_Pricing__c p : ppList){
            if(p.MACD_Type__c!=SIConstants.MACDTYPED && p.MACD_Type__c!=SIConstants.MACDTYPEC || (p.MACD_Type__c == SpecialCharacterConstant.CONCAT || p.MACD_Type__c == null)){
            pprcList.add(p);
            }
        }
        if(pprcList .size()>0){
        try {
        UpdateAmountOnProductPricing(newObjects);
            applyDiscountonInsert(newObjects);
        } catch(Exception excep) {
            ATTException.logException( excep.getTypeName(), ATTException.constructExceptionMessageString(excep));
            excep.getMessage();
            isExecuted = false;
            throw excep;
        }
    }
        return isExecuted;
    }
    
    //An Overridden method
/* 
 Name: onAfterInsert
 Description: 
 */ 
    public override boolean onAfterInsert(SObject[] newObjects) {
        
        MBC_Count_Increase_on_SPProduct(newObjects);
        List<Product_Pricing__c> ppList = newObjects;
        List<Product_Pricing__c> pprcList = new List<Product_Pricing__c>();
        Set<Id> addOptyIdSet = new Set<Id>() ;
        
            for(Product_Pricing__c p : ppList){
                if(p.MACD_Type__c!=SIConstants.MACDTYPED && p.MACD_Type__c!=SIConstants.MACDTYPEC){
                    pprcList.add(p);
                }
                if (p.MACD_Type__c == SIConstants.MACDTYPEA ) {
                    addOptyIdSet.add(p.Deal_Id__c) ;
                }
            }
         
            
        try {  
                if(pprcList .size()>0){ 
                updateSPProductsAfterDiscount(newObjects, newObjects, false);        
            }
         
        if(addOptyIdSet.size() > 0) {
               updateMACDPricingStatusOnOpty (addOptyIdSet);
             }
        
      
            } catch(Exception excep) {
                ATTException.logException( excep.getTypeName(), ATTException.constructExceptionMessageString(excep));
                excep.getMessage();
                isExecuted = false;
                throw excep;
            }
            return isExecuted;
    }
    
    //An Overridden method
/* 
 Name: onBeforeUpdate
 Description: 
 */ 
    public override boolean onBeforeUpdate(SObject[] oldObjects,SObject[] newObjects,Map<Id,SObject> newObjectsMap) {
     List<Product_Pricing__c> ppList = newObjects;
    List<Product_Pricing__c> pprcList = new List<Product_Pricing__c>();
    List<Product_Pricing__c> ppAList = new List<Product_Pricing__c>();
    
        for(Product_Pricing__c p : ppList){
            if(p.MACD_Type__c!=SIConstants.MACDTYPED && p.MACD_Type__c!=SIConstants.MACDTYPEC){
            pprcList.add(p);
            }
            if (p.MACD_Type__c == SIConstants.MACDTYPEA && p.MACD_Pricing_Assignment_Technical__c == True) {
                ppAList.add(p) ;
            }
        }
        try {
        if(pprcList .size()>0){
            if(!SIConstants.isDealRegApproval)
            {
              calculateDiscountOnUpdation(oldObjects, newObjects);
            }
        }
        if(ppAList.size() > 0) {
                UpdateAmountOnProductPricing(newObjects);
            }
            
        } catch(Exception excep) {
            ATTException.logException( excep.getTypeName(), ATTException.constructExceptionMessageString(excep));
             excep.getMessage();
            isExecuted = false;
            throw excep;
        }
        return isExecuted;
    }
    
/* 
 Name: onAfterUpdate
 Description: 
 */ 
    public override boolean onAfterUpdate(SObject[] oldObjects,SObject[] newObjects,Map<Id,SObject> newObjectsMap ){
    List<Product_Pricing__c> ppList = newObjects;
    List<Product_Pricing__c> pprcList = new List<Product_Pricing__c>();
    List<Product_Pricing__c> ppAList =  newObjects ;
    List<Product_Pricing__c> oldPPList = oldObjects ;
    Set<Id> addOptyIdSet = new Set<Id>() ;
    
        for(Product_Pricing__c p : ppList){
            if(p.MACD_Type__c!=SIConstants.MACDTYPED && p.MACD_Type__c!=SIConstants.MACDTYPEC){
            pprcList.add(p);
            }
            
        }
        
        for(Integer i=0; i < ppAList.size(); i++) {
        //for(Product_Pricing__c pp : newPPList) {
            if(ppAList[i].MACD_Type__c == SIConstants.MACDTYPEA) {
                addOptyIdSet.add(ppAList[i].Deal_Id__c) ;
            }           
        }
        try
        {
         if(pprcList .size()>0){
                if(!SIConstants.isDealRegApproval)
                {
                    updateSPProductsAfterDiscount(oldObjects,newObjects, true);
        }
                }
         if(addOptyIdSet.size() > 0) {
                    updateMACDPricingStatusOnOpty (addOptyIdSet);
                }
            }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            isExecuted=false;
            throw e;
        }
        return isExecuted;    
    }
    //An Overridden method
    /* 
     Name: onAfterDelete
     Description: 
     */ 
    public override boolean onAfterDelete(SObject[] oldObjects, Map<Id, SObject>  oldObjectsMap){
        try{          
                  MBC_Count_Decrease_on_SPProduct(oldObjects); 
             updateSPProductsAfterDelete(oldObjects); 
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            isExecuted=false;
            throw e;
        }    
        return isExecuted;
    }
    
  /* 
  Name: updateSPProductsAfterDelete
  Description:
  */ 
  public void updateSPProductsAfterDelete(SObject[] oldObjects)
  {
        try{
            list<Product_Pricing__c> prodPricingList= oldObjects;
            list <Product_Pricing__c> prodPricingCkecList = new list <Product_Pricing__c> ();
            set <Id> prodIdSet = new set <Id>();
            if(!prodPricingList.isEmpty() && prodPricingList!= null)
            {
                for (Product_Pricing__c pp : prodPricingList)
                {
                    prodIdSet.add(pp.Sp_Product__c);
                }
                
                if(!prodIdSet.isEmpty() && prodIdSet != null)
                {
                    list <SPProduct__c> updateList = doUpdateProducts(prodIdSet);
                    if(!updateList.isEmpty() && updateList != null)
                    {
                        update updateList;
                    }
                }
            }
        }catch(Exception ex)
        {
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }
  }
  
   /* 
   Name: doUpdateProducts
   Description: This is to update the SPProdcutn after updating the  Discounted Price or Discount Price
   */
  public void updateSPProductsAfterDiscount(SObject[] oldObjects,SObject[] newObjects, Boolean isUpdate)
  {
      try{
        list <Product_Pricing__c> oldList = oldObjects;
        list <Product_Pricing__c> newList = newObjects;
        set <Id> prodSet = new set <Id>();      
        if(!newList.isEmpty()&& newList!=null)
        {
            if(isUpdate)
            {
                for(Integer i=0;i<newList.size();i++)
                {
                    if((oldList[i].Discounted_Price__c!=newList[i].Discounted_Price__c || oldList[i].Discount_Price__c!=newList[i].Discount_Price__c || oldList[i].Type__c != newList[i].Type__c) && newList[i].Product_Record_Type__c!=SIConstants.PROD_Attwireless)
                    {
                        prodSet.add(newList[i].Sp_Product__c);
                    }
                }
            }
            else
            {
                for(Product_Pricing__c pp : newList)
                {
                    if((pp.Discounted_Price__c!=null || pp.Discount_Price__c!=null) && pp.Product_Record_Type__c!=SIConstants.PROD_Attwireless)
                    {
                        prodSet.add(pp.Sp_Product__c);
                    }
                }       
            }
            
            if(!prodSet.isEmpty() && prodSet!= null)
            {
                list <SPProduct__c> updateList = doUpdateProducts(prodSet);  
                if(!updateList.isEmpty()&&updateList!=null)
                {
                    update updateList;
                }   
            }           
        }  
      }catch(Exception ex)
        {
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }       
  }
  
  /* 
  Name: doUpdateProducts
  Description:This function is to apply discount on inserting a product pricing record after Deal Reg Approval
 */
  public void applyDiscountonInsert(SObject[] newObjects)
  {
      try{
        list <Product_Pricing__c> newList = newObjects;
        list<Product_Pricing__c> dealUpdateList = new list <Product_Pricing__c>();
        
        if(!newList.isEmpty() && newList != null)
        {
            for(Product_Pricing__c ppr : newList)
            {
                if(ppr.Product_Competitive_Status__c != SIConstants.PROD_COMP_PRI_APP && ppr.Product_Record_Type__c!=SIConstants.PROD_Attwireless)
                {
                    dealUpdateList.add(ppr);
                }
            }
        }
        if(!dealUpdateList.isEmpty() && dealUpdateList != null)
        {
            SIHelper.calculateDiscountonProductPricingRecords(dealUpdateList);  
        }
      }catch(Exception ex)
        {
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }       
  }
  
  /* 
  Name: doUpdateProducts
  Description: This function is to update SPProducts once any updates happend in Discount Price or Discounted Price field in Product  Pricing record or if we created new Product   Pricing record.
 */ 
  public list <SPProduct__c> doUpdateProducts(set<Id> prodSet)
  {
      try{
        list <SPProduct__c> prodList = new list <SPProduct__c>();
        if( !prodSet.isEmpty() && prodSet!=null && prodSet.size()>0 )
            {
                prodList = [SELECT Id,One_Time_Revenue_Discount_Price__c,Discounted_Price__c,isNRC__c FROM SPProduct__c sp WHERE sp.Id IN : prodSet];
                if(!prodList.isEmpty() && prodList!= null)
                {
                    for(SPProduct__c sp : prodList)
                    {
                        sp.One_Time_Revenue_Discount_Price__c = 0;
                        sp.Discounted_Price__c= 0;
                    }
                }
                AggregateResult[] groupedResults = [SELECT Sp_Product__c,Type__c, SUM(Discounted_Price__c) DiscountedPrice, SUM(Discount_Price__c) DiscountPrice FROM Product_Pricing__c WHERE Sp_Product__c IN : prodSet GROUP BY Sp_Product__c,Type__c];          
                if(!groupedResults.isEmpty() && groupedResults!=null)
                {
                    for(SPProduct__c sp : prodList)
                    {
                        for(AggregateResult agr : groupedResults)
                        {
                            if(agr.get('Sp_Product__c')==sp.Id)
                            {
                                if(agr.get('Type__c') == 'MRC')
                                {
                                    sp.Discounted_Price__c=(Decimal)agr.get('DiscountedPrice');
                                }
                                else if(agr.get('Type__c') == 'NRC')
                                {                               
                                    sp.One_Time_Revenue_Discount_Price__c=(Decimal)agr.get('DiscountedPrice');
                                }
                            }
                        }
                    }
                }
            }
            return prodList;
          }catch(Exception ex)
            {
                ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
                return null;
            }           
      }
      
      /* 
         Name: calculateDiscountOnUpdation
         Description: 
     */ 
      public void calculateDiscountOnUpdation(SObject[] oldObjects,SObject[] newObjects)
      {
         try{ 
            list <Product_Pricing__c> oldList = oldObjects;
            list <Product_Pricing__c> newList = newObjects; 
            list <Product_Pricing__c> updatableList = new list <Product_Pricing__c>();
            list <Product_Pricing__c> updatableSPList = new list <Product_Pricing__c>();
            
            list <SPProduct__c> spList = new list <SPProduct__c>();
            set <Id> prodIdSet = new set <Id>();
            
            if(!newList.isEmpty() && newList!= null)
            {
                for (Integer i=0; i<newList.size(); i++)
                {
                    
                        if(oldList[i].Type__c != null && newList[i].Type__c != null && newList[i].Product_Record_Type__c!=SIConstants.PROD_Attwireless)
                        {
                            if((oldList[i].list_price__c != newList[i].list_price__c || oldList[i].Usage_Charges__c != newList[i].Usage_Charges__c || oldList[i].Discountable__c != newList[i].Discountable__c || oldList[i].Type__c != newList[i].Type__c) && (newList[i].Type__c.equalsIgnoreCase(SIConstants.TYPE_NRC) || newList[i].Type__c.equalsIgnoreCase(SIConstants.TYPE_MRC) || newList[i].Type__c.equalsIgnoreCase(SIConstants.TYPE_MUC)))
                            {                       
                                if(newList[i].Product_Competitive_Status__c != SIConstants.PROD_COMP_PRI_APP)
                                {
                                    updatableList.add(newList[i]);
                                }
                                else
                                {
                                    updatableSPList.add(newList[i]);
                                }
                            }
                            else if(!(newList[i].Type__c.equalsIgnoreCase(SIConstants.TYPE_NRC) || newList[i].Type__c.equalsIgnoreCase(SIConstants.TYPE_MRC) ||newList[i].Type__c.equalsIgnoreCase(SIConstants.TYPE_MUC)))
                            {
                                newList[i].discount_price__c=0;
                                newList[i].Discounted_Price__c=0;
                                newList[i].Discounted_Usage_Charge__c=0;
                            }
                        }
                        else if((oldList[i].Type__c == null || newList[i].Type__c == null) && newList[i].Product_Record_Type__c!=SIConstants.PROD_Attwireless)
                        {
                            if(oldList[i].Type__c== null && newList[i].Type__c != null && (newList[i].Type__c.equalsIgnoreCase(SIConstants.TYPE_NRC) || newList[i].Type__c.equalsIgnoreCase(SIConstants.TYPE_MRC) ||  newList[i].Type__c.equalsIgnoreCase(SIConstants.TYPE_MUC)))
                            {
                                if(newList[i].Product_Competitive_Status__c != SIConstants.PROD_COMP_PRI_APP)
                                {
                                    updatableList.add(newList[i]);
                                }
                                else
                                {
                                    updatableSPList.add(newList[i]);
                                }
                            }
                            else if(oldList[i].Type__c != null && newList[i].Type__c == null)
                            {
                                newList[i].discount_price__c=0;
                                newList[i].Discounted_Price__c=0;
                                newList[i].Discounted_Usage_Charge__c=0;
                            }
                        }
                }
                
                if(!updatableList.isEmpty() && updatableList!=null)
                {
                    SIHelper.calculateDiscountonProductPricingRecords(updatableList);
                }
                if(!updatableSPList.isEmpty() && updatableSPList != null)
                {
                    for(Product_Pricing__c PP:updatableSPList)
                    {           
                        
                        if(!PP.Discountable__c)
                        {
                            if(PP.SP_Discount_Percentage__c!=null &&  PP.discount_price__c==0.00 )
                            {
                              if(PP.Record_Type__c==SIConstants.DISCOUNT_TYPE_USAGE){
                                 PP.Discounted_Usage_Charge__c=PP.Usage_Charges__c -SIHelper.Round4Digit((PP.Usage_Charges__c*PP.SP_Discount_Percentage__c)/100);
                              }else{
                                
                                PP.discount_price__c = SIHelper.applyRound((PP.list_price__c*PP.SP_Discount_Percentage__c)/100);
                                PP.discounted_price__c= PP.list_price__c - PP.discount_price__c; 
                              }
                            }
                        }   
                        else
                        {
                          if(PP.Record_Type__c==SIConstants.DISCOUNT_TYPE_USAGE){
                                PP.Discounted_Usage_Charge__c=PP.Usage_Charges__c;
                            
                          }else if(PP.discount_price__c==null || (PP.discount_price__c!=null && PP.discount_price__c==0.00)){
                            PP.discount_price__c =0;
                            PP.discounted_price__c = PP.list_price__c;
                          }
                        }                           
                    }
                }
            }
         }catch(Exception ex)
            {
                ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
            }   
      }
      
     /*US314885-To update Amount on MACDUtilityConstant.SPRODUCT_PRICING_FROM_MASTERs*/
    public void updateAmountOnProductPricing(SObject[] newObjects)
      {
      try{
         list <Product_Pricing__c> newList = newObjects;
         list <Product_Pricing__c> pplist = new list <Product_Pricing__c>();
         list <Rates__c> rateList = new list<Rates__c>();
         set <Id> prodIdSet = new set <Id>();
         list <Product_Pricing__c> newListToUpdate = new list <Product_Pricing__c>();
         list<SPProduct__c> splist = new list<SPProduct__c> ();   
         Set<Id> ppSetIds = new Set<Id>();
         Set<String> beidSet = new Set<String>();
         Set<String> pbinumberSet = new Set<String>();
         Set<String> deterSet = new Set<String>();
         Set<String> lowlevelSet = new Set<String>();
         list <Product_Pricing__c> insertPPrecords = new list <Product_Pricing__c>();
         List<Opportunity> optyList = new List<Opportunity>() ;
         Set<Id> optyIdSet = new Set<Id>();
         Set<String> dealRatePlanIdSet = new Set<String>();
         ID rtypeId = SIRecordTypeHelper.GetRecordTypeIdByDevName(UtilityConstant.PRODUCTPRICING_C,UtilityConstant.ACCESS);  
         //Id rtypeId = [select Id,Name,SobjectType from RecordType where DeveloperName ='Access' and SobjectType= 'Product_Pricing__c' limit 1].Id;
          for(Product_Pricing__c pp :newList){
             if( pp.X3rd_Party_Flag__c || pp.API_Flag__c) {
                 ppSetIds.add(pp.SP_Product__c); 
                 beidSet.add(pp.BEID__c);
                 pbinumberSet .add(pp.PBI_Number__c);
                 deterSet .add(pp.Determinant_Set_ID__c);
                 lowlevelSet .add(pp.Low_Level_Tier__c);         
                 optyIdSet.add(pp.OpptyID__c) ;  
                 dealRatePlanIdSet.add(pp.Deal_Rate_Plan_ID__c);          
             }
         }

       // optyList = [Select Id, Name,Deal_Rate_Plan_ID__c,isRetriggerMACDPricingAssgnmnt__c,MACD_Pricing_Assignment_Status__c from Opportunity Where Id=: optyIdSet and Deal_Rate_Plan_ID__c in:dealRatePlanIdSet ] ;
       
        
         if(ppSetIds.size()>0 && optyIdSet.size()>0){
            optyList = [Select id, Discounted_Percentage__c,Record_Type_Name_for_Internal_use__c, MACD_Type__c FROM Opportunity where id IN:optyIdSet AND Record_Type_Name_for_Internal_use__c =:SIConstants.RECORDTYPEMACD AND MACD_Type__c =:SIConstants.MACDTYPEA];
             if( dealRatePlanIdSet.size() > 0 ) {
                 splist=[Select id,Oppty_Record_Type__c,MACDTypeOnOpp__c,Deal_Rate_Plan_ID__c FROM SPProduct__c where Oppty_Record_Type__c =:SIConstants.RECORDTYPEMACD and MACDTypeOnOpp__c =:SIConstants.MACDTYPEA and id in:ppSetIds and Deal_Rate_Plan_ID__c in:dealRatePlanIdSet];
                 if( deterSet.size() > 0 && pbinumberSet.size() > 0 && lowlevelSet.size() > 0 ){
                 rateList = [Select id,Rate_Plan_Id_Technical__c,Billing_Element__c, BEID__c,Determinant_Set_ID__c,PBI_Number__c,Low_Level__c,Amount__c FROM Rates__c where BEID__c in:beidSet and Determinant_Set_ID__c in:deterSet  and PBI_Number__c in:pbinumberSet  and Low_Level__c in:lowlevelSet and Billing_Element__c =:UtilityConstant.MTHLYSVC and Rate_Plan_Id_Technical__c in:dealRatePlanIdSet];
                  }
             }
             if(splist.size()>0 && optyList.size()>0){
              for(Opportunity oppty:optyList){
                 for(Product_Pricing__c pp:newList){
                     for(SPProduct__c sp:splist){
                        if(rateList.size()>0 && pp.RecordTypeId!=rtypeId && sp.id==pp.SP_Product__c && sp.Oppty_Record_Type__c==SIConstants.RECORDTYPEMACD && sp.MACDTypeOnOpp__c==SIConstants.MACDTYPEA){
                             for(Rates__c rate:rateList){
                               if(rate.Amount__c!=null && rate.BEID__c ==pp.BEID__c && rate.Determinant_Set_ID__c ==pp.Determinant_Set_ID__c && rate.PBI_Number__c ==pp.PBI_Number__c && rate.Low_Level__c==pp.Low_Level_Tier__c && rate.Billing_Element__c == UtilityConstant.MTHLYSVC)
                                {
                                 pp.list_price__c=rate.Amount__c; //assigning value of amount from Rates to product pricing
                                 if(pp.list_price__c!=null && oppty.Discounted_Percentage__c!=null){
                                                     pp.discount_price__c = (pp.list_price__c*oppty.Discounted_Percentage__c/100);
                                 pp.discounted_price__c = pp.list_price__c - pp.discount_price__c;
                                 }
                                 pp.Is_ListPrice_Latest__c = True;
                                 if(pp.MACD_Pricing_Assignment_Technical__c == True) {
                                    pp.MACD_Pricing_Assignment_Technical__c = False ;
                                 }
                                } 
                                                                  
                                    newListToUpdate.add(pp); 
                             }
                         }
                         if(pp.RecordTypeId==rtypeId && sp.id==pp.SP_Product__c && sp.Oppty_Record_Type__c==SIConstants.RECORDTYPEMACD && sp.MACDTypeOnOpp__c==SIConstants.MACDTYPEA)
                         {
                          pp.discount_price__c = (pp.list_price__c*(oppty.Discounted_Percentage__c/100));
                          pp.discounted_price__c = pp.list_price__c - pp.discount_price__c;
                          pp.Is_ListPrice_Latest__c = True;
                          newListToUpdate.add(pp);
                         }
                     }
                 }
             }
             }
             }
             
         
         if(newListToUpdate.size()>0)
        {
         try{
             update newListToUpdate;
            }
        catch(Exception ex)
             {
              ex.getMessage();
             }
       }
      }catch(Exception ex)
        {
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }  
 }
    /*To update MACD Pricing Assignment status on Oppty on click of retrigger button*/   
/* 
 Name: updateMACDPricingStatusOnOpty
 Description: 
 */ 
    public void updateMACDPricingStatusOnOpty (Set<Id> addOptyIdSet) {
      try{  
        List<Product_Pricing__c> newPPList = new List<Product_Pricing__c>() ;
        List<Product_Pricing__c> oldPPList = new List<Product_Pricing__c>() ; 
        Set<Id> updateOptyIdSet = new Set<Id>() ;
        List<Opportunity> updateOptyList = new List<Opportunity>() ;
        List<Product_Pricing__c> updatePPList = new List<Product_Pricing__c>() ;  
        Map<Id, Opportunity> updateOptyMap = new Map<Id, Opportunity>() ;
        updateOptyIdSet = addOptyIdSet ;
        //Id rtypeId = [select Id,Name,SobjectType from RecordType where DeveloperName ='Access' and SobjectType= 'Product_Pricing__c' limit 1].Id;
        Id rtypeId= SIRecordTypeHelper.GetRecordTypeIdByDevName(UtilityConstant.PRODUCTPRICING_C,UtilityConstant.ACCESS);      
        if(updateOptyIdSet.size() > 0) {
            updateOptyList = [Select Id, Name,isRetriggerMACDPricingAssgnmnt__c,MACD_Pricing_Assignment_Status__c from Opportunity Where Id=: updateOptyIdSet] ;
            updatePPList = [Select Id, Name,Is_ListPrice_Latest__c,RecordTypeId, list_price__c, Deal_Id__c from Product_Pricing__c Where Deal_Id__c =: updateOptyIdSet] ;
        }
         if(updateOptyList.size() > 0 && updatePPList.size() > 0) {
               
            for(Opportunity op : updateOptyList) {
                 for(Product_Pricing__c pp : updatePPList) {
                      if(op.Id == pp.Deal_Id__c && pp.Is_ListPrice_Latest__c==true) {
                        op.MACD_Pricing_Assignment_Status__c = UtilityConstant.SUCCESS ;
                        updateOptyMap.put(op.Id, op) ;
                    }
                   
                    else if(op.Id == pp.Deal_Id__c && pp.Is_ListPrice_Latest__c==false) {
                        op.MACD_Pricing_Assignment_Status__c = UtilityConstant.FAILURE ;
                        updateOptyMap.put(op.Id, op) ;
                        break ;
                    }
                }
            }
        }
        
        if(updateOptyMap.size() > 0) {
            try {
                update updateOptyMap.values() ;
            }
            catch(Exception e) {
                e.getMessage();
            }
        }
      }catch(Exception ex)
        {
            ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
        }   
    }
   
    /*
    Name: mbc_Count_Increase_on_SPProduct
     Description: 
    */
    public void mbc_Count_Increase_on_SPProduct(SObject[] newObjects)
    {
      try{
        List<Product_Pricing__c> ppList=newObjects;
        Set<Id> ppspproductSet=new Set<Id>();  
        List<SPProduct__c> spList=new  List<SPProduct__c>();
        Map<Id,SPProduct__c> spMap=new Map<Id,SPProduct__c>();
        List<SPProduct__c> spproductList=new  List<SPProduct__c>();
        Map<Id,SPProduct__c> spproductMap=new  Map<Id,SPProduct__c>();
        for(Product_Pricing__c pp:ppList)
        {
            if(pp.Product_Detail__c == UtilityConstant.MINIMUMBANDWIDTHCOMMITMENT && pp.Record_Type__c == UtilityConstant.FEATURE)
            {
                ppspproductSet.add(pp.SP_Product__c);
            }
        }
            if(ppspproductSet.size()>0)
            {
               spList=[select Id,MBC_Counter__c from SPProduct__c WHERE Id IN:ppspproductSet]; 
            }
            if(spList.size()>0)
            {            
                for(SPProduct__c spp:spList)
                    {
                       for(Product_Pricing__c ppc:ppList)
                       { 
                       
                        if(ppc.SP_Product__c == spp.Id && spp.MBC_Counter__c==NULL)
                        {
                           spp.MBC_Counter__c=0;
                           spMap.put(spp.Id,spp);                      
                         }                                                          
                    }
                    
                }
            }
            if(spMap.size()>0)
            {
                try
                {
                    update spMap.values();
                }
                Catch(Exception e)
                {
                    e.getMessage();
                }
           }
           if(ppspproductSet.size()>0)
            {
               spproductList=[select Id,MBC_Counter__c from SPProduct__c WHERE Id IN:ppspproductSet]; 
            }  
            
            if(spproductList.size()>0)
              {
               for(SPProduct__c sp:spproductList)
               {
                   for(Product_Pricing__c pp:ppList)
                   {
                        if(pp.SP_Product__c == sp.Id && pp.Product_Detail__c == UtilityConstant.MINIMUMBANDWIDTHCOMMITMENT && pp.Record_Type__c == UtilityConstant.FEATURE && sp.MBC_Counter__c!=NULL)
                        {
                          sp.MBC_Counter__c++;
                          spproductMap.put(sp.Id,sp);                                                              
                        }
                   }
               }
          }
             if(spproductMap.size()>0)
            {
                try
                {
                    update spproductMap.values();
                }
                Catch(Exception e)
                {
                    e.getMessage();
                }
                
            }  
      }catch(Exception ex)
            {
                ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
            }   
    }
    
    /*
     Name: mbc_Count_Decrease_on_SPProduct
     Description: 
    */
    public void mbc_Count_Decrease_on_SPProduct(SObject[] oldObjects)
    {
        try{
            List<Product_Pricing__c> ppList=oldObjects;
            Set<Id> ppspproductSet=new Set<Id>();
            List<SPProduct__c> spList=new  List<SPProduct__c>();
            Map<Id,SPProduct__c> spMap=new Map<Id,SPProduct__c>();
            for(Product_Pricing__c pp:ppList)
            {
                if(pp.Product_Detail__c == UtilityConstant.MINIMUMBANDWIDTHCOMMITMENT && pp.Record_Type__c == UtilityConstant.FEATURE)
                {
                    ppspproductSet.add(pp.SP_Product__c);
                }
            }
            if(ppspproductSet.size()>0)
                {
                   spList=[select Id,MBC_Counter__c from SPProduct__c WHERE Id IN:ppspproductSet]; 
                }
            if(spList.size()>0)
                {            
                    for(SPProduct__c spp:spList)
                        {
                           for(Product_Pricing__c ppc:ppList)
                           { 
                           
                            if(ppc.SP_Product__c == spp.Id && spp.MBC_Counter__c>0 && spp.MBC_Counter__c!=NULL)
                            {
                               spp.MBC_Counter__c--;
                               spMap.put(spp.Id,spp);                      
                            }
                            else if(ppc.SP_Product__c == spp.Id && spp.MBC_Counter__c==NULL)
                            {
                               spp.MBC_Counter__c=0;
                               spMap.put(spp.Id,spp); 
                            }                                                           
                        }
                   }
                } 
                   
            if(spMap.size()>0)
                {
                    try
                    {
                        update spMap.values();
                    }
                    Catch(Exception e)
                    {
                        e.getMessage();
                    }
               } 
           }catch(Exception ex)
            {
                ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));
            } 
    }   
}