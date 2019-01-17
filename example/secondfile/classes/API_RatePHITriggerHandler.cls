/*
     Component Name :API_RatePHITriggerHandler 
     Requirement/User Story Number :
     Requirement Description:Update Tier and Term from Rate Plan Name on Record Creation and Update
     Component Author:Accenture IDC
     Created Date:26th May 2014 
     Version:1.0
     Last Modified By: Accenture IDC
     updateDiscountedCheckbox : this method is create discounr plan of feature type
    */
    
/* 
 Name: SITriggerOperations.SITriggerImpl
 Type: Class 
 
 Description: 
 */ 
public with sharing class API_RatePHITriggerHandler extends SITriggerOperations.SITriggerImpl{
   /* To be used for Before Insert Operations*/
    public override boolean onBeforeInsert (SObject[] newObjects)
    {
        try
        {
         deriveTermAndTierValues(newObjects);
        }
        catch (exception e)
        {
           e.getMessage();
           ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));    
        }
        return true;
    }
    
      

   // To be used for Future after insert operations 
/*    public override boolean onAfterInsert (SObject[] newObjects)
    {
        try
        {
           
        }
        catch (exception e)
        {
            e.getMessage();
        }
        return true;
    } */
    
    
    /* To be used for Before Update Operations */
    public override boolean onBeforeUpdate(SObject[] oldObjects, SObject[] updatedObjects, Map<Id, SObject>  newObjectsMap)
    {
        try
        {
        //  updateTermAndTierValues(oldObjects, updatedObjects);  
       // updateEffectiveDateAndVersion(updatedObjects,oldObjects);
     
        }
        catch (exception e)
        {
            e.getMessage();
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return true;
    }  
    
    
    /* To be used for Future After Update Operations */
    public override boolean onAfterUpdate(SObject[] oldObjects, SObject[] updatedObjects, Map<Id, SObject>  newObjectsMap)
    {
        try
        {
             updateDiscountedCheckbox(updatedObjects); 
             updateTempAndPreviousAmount(updatedObjects);
             //updateEffectiveDateAndVersion(updatedObjects,oldObjects);
             updateTierFields(oldObjects,updatedObjects);   
           
        }
        catch (exception e)
        {
              e.getMessage();
              ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return true;
    } 

/* Logic to Insert values into Fields Term and Tier from Rate Plan Name when Rate PHI record is created */    
              
/* 
 Name: deriveTermAndTierValues
 Description: 
 */ 
    public void deriveTermAndTierValues(SObject[] newObjects){
        try{
        List<Rate_PHI__c> ratePHIRecordsToBeInserted = new List<Rate_PHI__c>(); 
        List<Rate_PHI__c> ratePHIInserted=newObjects;
         
            for(Rate_PHI__c ratePHINewDets: ratePHIInserted){
                    if(ratePHINewDets.Rate_Plan_Name__c.contains(SIConstants.TERMONE)){
                    ratePHINewDets.Term__c = Integer.ValueOf(SIConstants.TERMONE);
                    ratePHIRecordsToBeInserted.add(ratePHINewDets);
                    } 
                    else if(ratePHINewDets.Rate_Plan_Name__c.contains(SIConstants.TERMTWO)){
                    ratePHINewDets.Term__c = Integer.ValueOf(SIConstants.TERMTWO);
                    ratePHIRecordsToBeInserted.add(ratePHINewDets);
                    }
                    else if(ratePHINewDets.Rate_Plan_Name__c.contains(SIConstants.TERMTHREE)){
                    ratePHINewDets.Term__c = Integer.ValueOf(SIConstants.TERMTHREE);
                    ratePHIRecordsToBeInserted.add(ratePHINewDets);
                    } 
                    else if(ratePHINewDets.Rate_Plan_Name__c.contains(SIConstants.TERMFOUR)){
                    ratePHINewDets.Term__c = Integer.ValueOf(SIConstants.TERMFOUR);
                    ratePHIRecordsToBeInserted.add(ratePHINewDets);
                    }
                    else if(ratePHINewDets.Rate_Plan_Name__c.contains(SIConstants.TERMFIVE)){
                    ratePHINewDets.Term__c = Integer.ValueOf(SIConstants.TERMFIVE);
                    ratePHIRecordsToBeInserted.add(ratePHINewDets);
                    }
                    
                    if(ratePHINewDets.Rate_Plan_Name__c.contains(SIConstants.TIERPLATINUM)){
                    ratePHINewDets.Tier__c = SIConstants.TIERPLATINUM;
                    ratePHIRecordsToBeInserted.add(ratePHINewDets);
                    }
                    else if(ratePHINewDets.Rate_Plan_Name__c.contains(SIConstants.TIERGOLD)){
                    ratePHINewDets.Tier__c = SIConstants.TIERGOLD;
                    ratePHIRecordsToBeInserted.add(ratePHINewDets);
                    }
                    else if(ratePHINewDets.Rate_Plan_Name__c.contains(SIConstants.TIERSILVER)){
                    ratePHINewDets.Tier__c = SIConstants.TIERSILVER;
                    ratePHIRecordsToBeInserted.add(ratePHINewDets);
                    } 
            }
        }catch(Exception e){
    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
    } 
/* 
 Name: updateDiscountedCheckbox
 Description: 
 */ 
    public void updateDiscountedCheckbox(SObject[] updatedObjects){
        
        //List<Rate_PHI__c> listOfratePHIFailed = new List<Rate_PHI__c>();
        List<Rate_PHI__c> ratePHIUpdated=updatedObjects;
        Set<Id> setOfFailedPHIids = new Set<Id>();
        Set<Id> setOfSuccessPHIids = new Set<Id>();
        for(Rate_PHI__c phi:ratePHIUpdated){
            if(phi.Discount_Plan_Status__c == UtilityConstant.CREATEDISCOUNT_PLAN_FAILED){
                setOfFailedPHIids.add(phi.id);
            }
            if(phi.Discount_Plan_Status__c == UtilityConstant.CREATEDISCOUNT_PLAN_SUCCESSFUL){
                setOfSuccessPHIids.add(phi.id);
            }
        }
        //Logic on Failure of Discount PLan status. The discounted checkbox will be set to false
        List<Rates__c> listOfRatesRelatedTofailedPHI = new List<Rates__c>();
        List<Rates__c> listOfnewRatesRelatedTofailedPHI = new List<Rates__c>();//to set the current PBI discounted flagto flase on failure
        listOfRatesRelatedTofailedPHI = [Select id,Old_PBI_Id__c,Discounted_Already__c from Rates__c where Rate_PHI__c in:setOfFailedPHIids];
        Set<Id> failedPbi = new Set<Id>();
        if(listOfRatesRelatedTofailedPHI.size()>0){
            for(Rates__c pbi :listOfRatesRelatedTofailedPHI){
                failedPbi.add(pbi.Old_PBI_Id__c);
                if(pbi.Discounted_Already__c == true){
                    pbi.Discounted_Already__c = false;
                    listOfnewRatesRelatedTofailedPHI.add(pbi);
                }
            }
        }
        List<Rates__c> listOfoldRates =[Select id,Old_PBI_Id__c,Discounted_Already__c from Rates__c where id in:failedPbi];
        List<Rates__c> listOfratePBItobeupdated = new List<Rates__c>();
        if(listOfoldRates.size()>0){
            for(Rates__c oldPBI: listOfoldRates){
                if(oldPBI.Discounted_Already__c == true){        
                    oldPBI.Discounted_Already__c = false;   
                    listOfratePBItobeupdated.add(oldPBI);  
                       
                }
            }
        }
        try{
            if(listOfratePBItobeupdated.size()>0){
                update listOfratePBItobeupdated ; 
            }
            if(listOfnewRatesRelatedTofailedPHI.size()>0){
                update listOfnewRatesRelatedTofailedPHI ;     
            }
        }Catch(Exception e){
        }
        //Logic for failed Ends
        
        //Logic for successful discount plan status on retrigger to set discounted flag back to true.
        List<Rates__c> listOfRatesRelatedToSuccessPHI = new List<Rates__c>();
        List<Rates__c> listOfnewRatesRelatedToSuccessPHI = new List<Rates__c>();
        listOfRatesRelatedToSuccessPHI = [Select id,Old_PBI_Id__c,Discounted_Already__c from Rates__c where Rate_PHI__c in:setOfSuccessPHIids];
        Set<Id> successPbi = new Set<Id>();
        if(listOfRatesRelatedToSuccessPHI.size()>0){
            for(Rates__c pbi :listOfRatesRelatedToSuccessPHI){
                SuccessPbi.add(pbi.Old_PBI_Id__c);
                if(pbi.Discounted_Already__c == false){
                    pbi.Discounted_Already__c = true;
                    listOfnewRatesRelatedToSuccessPHI.add(pbi);
                }
            }
        }
        List<Rates__c> listOfoldPbionsucc =[Select id,Old_PBI_Id__c,Discounted_Already__c from Rates__c where id in:SuccessPbi];
        List<Rates__c> listOfratePBItobeupdatedonsucc = new List<Rates__c>();
        if(listOfoldPbionsucc.size()>0){
            for(Rates__c oldPBI: listOfoldPbionsucc ){
                if(oldPBI.Discounted_Already__c == false){        
                    oldPBI.Discounted_Already__c = true;   
                    listOfratePBItobeupdatedonsucc.add(oldPBI);  
                       
                }
            }
        }
        try{
            if(listOfratePBItobeupdatedonsucc.size()>0){
            update listOfratePBItobeupdatedonsucc; 
            }
            if(listOfnewRatesRelatedToSuccessPHI.size()>0){
            update listOfnewRatesRelatedToSuccessPHI;     
            }
        }Catch(Exception e){
        }
        //logic for success ends
    }
        
/* Logic to Update Fields Term and Tier from Rate Plan Name if Rate Plan Name is updated */    
              
/*  public void updateTermAndTierValues(SObject[] oldObjects, SObject[] updatedObjects){
    
        List<Rate_PHI__c> ratePHIRecordsToBeUpdatedted = new List<Rate_PHI__c>(); 
        List<Rate_PHI__c> ratePHIUpdated=updatedObjects;
        List<Rate_PHI__c> oldRatePHI=oldObjects;
         
            for(Rate_PHI__c ratePHIDets: ratePHIUpdated){
                for(Rate_PHI__c oldRatePHIDets: oldRatePHI){
                if (oldRatePHIDets.Rate_Plan_Name__c != ratePHIDets.Rate_Plan_Name__c){
                    if(ratePHINewDets.Rate_Plan_Name__c.contains(SIConstants.TERMONE)){
                    ratePHINewDets.Term__c = Integer.ValueOf(SIConstants.TERMONE);
                    ratePHIRecordsToBeInserted.add(ratePHINewDets);
                    } 
                    else if(ratePHINewDets.Rate_Plan_Name__c.contains(SIConstants.TERMTWO)){
                    ratePHINewDets.Term__c = Integer.ValueOf(SIConstants.TERMTWO);
                    ratePHIRecordsToBeInserted.add(ratePHINewDets);
                    }
                    else if(ratePHINewDets.Rate_Plan_Name__c.contains(SIConstants.TERMTHREE)){
                    ratePHINewDets.Term__c = Integer.ValueOf(SIConstants.TERMTHREE);
                    ratePHIRecordsToBeInserted.add(ratePHINewDets);
                    } 
                    else if(ratePHINewDets.Rate_Plan_Name__c.contains(SIConstants.TERMFOUR)){
                    ratePHINewDets.Term__c = Integer.ValueOf(SIConstants.TERMFOUR);
                    ratePHIRecordsToBeInserted.add(ratePHINewDets);
                    }
                    else if(ratePHINewDets.Rate_Plan_Name__c.contains(SIConstants.TERMFIVE)){
                    ratePHINewDets.Term__c = Integer.ValueOf(SIConstants.TERMFIVE);
                    ratePHIRecordsToBeInserted.add(ratePHINewDets);
                    }
                    
                    if(ratePHINewDets.Rate_Plan_Name__c.contains(SIConstants.TIERPLATINUM)){
                    ratePHINewDets.Tier__c = SIConstants.TIERPLATINUM;
                    ratePHIRecordsToBeInserted.add(ratePHINewDets);
                    }
                    else if(ratePHINewDets.Rate_Plan_Name__c.contains(SIConstants.TIERGOLD)){
                    ratePHINewDets.Tier__c = SIConstants.TIERGOLD;
                    ratePHIRecordsToBeInserted.add(ratePHINewDets);
                    }
                    else if(ratePHINewDets.Rate_Plan_Name__c.contains(SIConstants.TIERSILVER)){
                    ratePHINewDets.Tier__c = SIConstants.TIERSILVER;
                    ratePHIRecordsToBeInserted.add(ratePHINewDets);
                    }
                } 
                }
            }
    } */ 
    /*void getAdminControlTocheckIfAmountEditAllowed(SObject[] newObjects){ 

    List<Rate_PHI__c> listOfratePhi = newObjects;
    List<Rate_PHI__c> listOfratePhiToUpdate = new List<Rate_PHI__c>();
    Admin_Control__c admincontrol = new Admin_Control__c();
    List<String> MasterEditStartTime = new List<String>();
    List<String> MasterEditEndTime = new List<String>();
    List<String> CurrentDate;
    List<String> CurrentStringTime;
    List<String> CurrentTime;
    
    admincontrol=[select Id,Master_Edit_Start_Time__c,Master_Edit_End_Time__c,Master_Rate_Edit_Day__c,Master_Rate_Edit_Occurrence__c from Admin_Control__c limit 1];
    // The above line will query record from the admin control object

    Datetime dt = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));//creating date Insatnce,returns today date
    String dayOfWeek=dt.format(SIConstants.weekcode);// returns week of the day. for example:returns wednesday if today is wednesday
    Date myDate = Date.Today();//creating date instance
    String sDate = String.valueOf(myDate);//parsing date to string
    CurrentDate=sDate.split(SpecialCharacterUtilityConstant.HYPHEN);//splitting date
    String CurrentWeek; 
   

    if( Integer.ValueOf(CurrentDate[2])>0 &&  Integer.ValueOf(CurrentDate[2])<=7) //checking condition that the today date belongs to which week of present month
    {
        CurrentWeek=SIConstants.TERMONE; 
    }

    else if( Integer.ValueOf(CurrentDate[2])>7 &&  Integer.ValueOf(CurrentDate[2])<=14)
    {
        CurrentWeek=SIConstants.TERMTWO;
    }    
    else if( Integer.ValueOf(CurrentDate[2])>14 &&  Integer.ValueOf(CurrentDate[2])<=21)       
    {
        CurrentWeek=SIConstants.TERMTHREE;
    } 
    else if( Integer.ValueOf(CurrentDate[2])>21 &&  Integer.ValueOf(CurrentDate[2])<=28) 
    {
        CurrentWeek=SIConstants.TERMFOUR; 
    }
    else if( Integer.ValueOf(CurrentDate[2])>28 &&  Integer.ValueOf(CurrentDate[2])<=31)
    {
        CurrentWeek=SIConstants.TERMFIVE;
    } 

    datetime myDateTime = System.now();  //returns present time
    String stime = String.valueOf(myDateTime); //parsing to string
    CurrentStringTime=stime.split(SpecialCharacterUtilityConstant.BLANK);//splitting
    String cst=CurrentStringTime[1];//assigning time to string
    CurrentTime=cst.split(SpecialCharacterUtilityConstant.COLEN);//splitting
    String mest;
    String meet;
    
    if(admincontrol.Master_Edit_Start_Time__c!=NULL && admincontrol.Master_Edit_End_Time__c!=NULL)
    {
        mest=admincontrol.Master_Edit_Start_Time__c; //assigning master edit start time  of admin control object to string variable
        meet=admincontrol.Master_Edit_End_Time__c;//assigning master edit end time of admin control object to string variable
    }

    MasterEditStartTime=mest.split(SpecialCharacterUtilityConstant.COLEN);//splitting
    MasterEditEndTime=meet.split(SpecialCharacterUtilityConstant.COLEN);//splitting
    
    for(Rate_PHI__c phi:listOfratePhi){
        if(dayOfWeek==admincontrol.Master_Rate_Edit_Day__c && CurrentWeek==admincontrol.Master_Rate_Edit_Occurrence__c && Integer.ValueOf(CurrentTime[0])>=Integer.ValueOf(MasterEditStartTime[0]) && Integer.ValueOf(CurrentTime[0])<=Integer.ValueOf(MasterEditEndTime[0])&& phi.Rate_Sync_Status__c!=UtilityConstant.SUCCESS)
        {    
             phi.IsAmountEditAllowed__c = true;
             listOfratePhiToUpdate.add(phi);            
        }
        else{
            phi.IsAmountEditAllowed__c = false;
             listOfratePhiToUpdate.add(phi); 
        }
    }
    //update listOfratePhiToUpdate;   
    } 
    */
   public void updateTempAndPreviousAmount(SObject[] newObjects)
{
    try{
        List<Rate_PHI__c> listOfratePhi = newObjects;
        List<Rates__c> listOfrates = new List<Rates__c>();
        List<Rates__c> listOfRateTierToUpdate = new List<Rates__c>();
        Set<Id> successPhi = new Set<Id>();
         List<Product_Pricing__c>updatedPPList = new List<Product_Pricing__c>();
       
        for(Rate_PHI__c phi:listOfratePhi )
        {
        
            if(phi.Rate_Sync_Status__c == UtilityConstant.SUCCESS)
            {            
                successPhi.add(phi.id);    
            }
        
        }
        
        listOfrates = [Select id,Name,Rate_Plan_Id_Technical__c,Billing_Element__c,Amount__c,BEID__c,Determinant_Set_ID__c,PBI_Number__c,PHI_Id_onTier__c,Low_Level__c,Temp_Amount__c,Ready_for_Sync__c,Previous_Amount__c from Rates__c where Rate_PHI__c in:successPhi];
       
        if(listOfrates.size()>0)
        {
             for(Rates__c rateTier :listOfrates)
             {                       
                    
                    if(rateTier.Temp_Amount__c != rateTier.Amount__c && rateTier.Temp_Amount__c != null && rateTier.Ready_for_Sync__c == true){
                       
                        Decimal tmpStr=rateTier.Previous_Amount__c;
                        rateTier.Previous_Amount__c=rateTier.Amount__c;
                        rateTier.Amount__c=rateTier.Temp_Amount__c;
                        rateTier.Temp_Amount__c = tmpStr;
                                          
                        rateTier.Temp_Amount__c = null; 
                        rateTier.Ready_for_Sync__c = false;
                        rateTier.IsRateSyncSuccess__c = true;
                        
                        listOfRateTierToUpdate.add(rateTier);
                        }
    /*To update amount on Product Pricing for MACD Add when the amount on Rate is updated*/
 
    Id rtypeId = [select Id,Name,SobjectType from RecordType where DeveloperName ='Access' and SobjectType= 'Product_Pricing__c' limit 1].Id;
   // List<Opportunity> oppList = new List<Opportunity>();
    
    for(Product_Pricing__c pp:[Select id,list_price__c,discount_price__c,discounted_price__c,OpptyID__c,Is_ListPrice_Latest__c,RecordTypeId,Deal_Rate_Plan_ID__c,SP_Product__c,Amount__c,BEID__c,Determinant_Set_ID__c,PBI_Number__c,Low_Level_Tier__c from Product_Pricing__c where BEID__c=:rateTier.BEID__c AND Determinant_Set_ID__c=:rateTier.Determinant_Set_ID__c AND PBI_Number__c=:rateTier.PBI_Number__c AND Low_Level_Tier__c =:rateTier.Low_Level__c AND Deal_Rate_Plan_ID__c=:rateTier.Rate_Plan_Id_Technical__c])
     {    
       for(SPProduct__c sp:[Select id,Deal_Rate_Plan_ID__c,Oppty_Record_Type__c,MACDTypeOnOpp__c FROM SPProduct__c where id=:pp.SP_Product__c and Deal_Rate_Plan_ID__c=:pp.Deal_Rate_Plan_ID__c and Oppty_Record_Type__c =:SIConstants.RECORDTYPEMACD and MACDTypeOnOpp__c =:SIConstants.MACDTYPEA])
       {
       for(Opportunity opp:[Select id, Discounted_Percentage__c,Record_Type_Name_for_Internal_use__c, MACD_Type__c FROM Opportunity where id =:pp.OpptyID__c AND Record_Type_Name_for_Internal_use__c=:SIConstants.RECORDTYPEMACD AND MACD_Type__c =:SIConstants.MACDTYPEA])
       {
       if(rateTier.Billing_Element__c == UtilityConstant.MTHLYSVC && pp.RecordTypeId!=rtypeId && sp.id==pp.SP_Product__c && rateTier.Amount__c!=null)
        {
          pp.list_price__c = rateTier.Amount__c;
          if(pp.list_price__c!=null)
          {
            pp.discount_price__c = (pp.list_price__c*opp.Discounted_Percentage__c/100);
            pp.discounted_price__c = pp.list_price__c - pp.discount_price__c;
          }
          pp.Is_ListPrice_Latest__c  = True;
         }
       }
        updatedPPList.add(pp);
                
     }
     }
     }
     }
                
               
                                    
                 
        if(listOfRateTierToUpdate.size()>0)
        {
            update listOfRateTierToUpdate;
            update updatedPPList;
        }        
       }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            } 
    } 
  /*Name:UpdateTierFields*/  
  public void updateTierFields(SObject[] oldObjects, SObject[] newobjects)
  {
      
      List<Rate_PHI__c> ratePHINewrecords = newObjects;
      List<Rate_PHI__c> ratePHIOldrecords= oldObjects;
      Set<Id>  failurePHIIdSet=new Set<Id>();
      List<Rate_PHI__c> listofphirecords=new List<Rate_PHI__c>();
      List<Rates__c> listofRaterecords=new List<Rates__c>();
      List<Rates__c> listoftierrecords=new List<Rates__c>();
      Set<Id> ratesIdsSet=new Set<Id>();
      Map<Id,Rates__c> rateTierMap=new Map<Id,Rates__c>();
      
      for(Integer i=0;i<RatePHINewrecords.size();i++)
      {
         if(RatePHINewrecords[i].Rate_Sync_Status__c!=NULL && RatePHINewrecords[i].Rate_Sync_Status__c == SIConstants.FailureStatus)
         {
            FailurePHIIdSet.add(RatePHINewrecords[i].Id);
         }
      }
      
      if(FailurePHIIdSet.size()>0)
      {
       listofRaterecords=[Select id,Name,PHI_Id_onTier__c,Ready_for_Sync__c,isTierStatusFailed__c from Rates__c where Rate_PHI__c in:FailurePHIIdSet];
      }  
      
    /*if(listofRaterecords.size()>0){
            for(Rates__c pbi:listofRaterecords){
                        
                ratesIdsSet.add(pbi.id);
            }
        } 
    if(ratesIdsSet.size()>0)
    {
      listoftierrecords=[Select id,Name,PHI_Id_onTier__c,Ready_for_Sync__c,isTierStatusFailed__c from Rates__c  where id in :ratesIdsSet];
    }*/
    
    if(listofRaterecords.size()>0)
    {
     for(Rates__c rtier:listofRaterecords)
     {
       for(Rate_PHI__c rphi:RatePHINewrecords)
       {
          if(rtier.PHI_Id_onTier__c == rphi.Id && rtier.Ready_for_Sync__c == true)
          {
              rtier.isTierStatusFailed__c=true;
              RateTierMap.put(rtier.Id,rtier);          
          }
         
       }
     }
     }
      
   try
   {
     if(RateTierMap.size()>0)
     {
      update RateTierMap.values();
     }
   }
   Catch(Exception e)
   {
       ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
   }    
  }
/*  public void updateEffectiveDateAndVersion(SObject[] newObjects,SObject[] oldObjects) 
  {
    List<Rate_PHI__c> listOfratePhi = newObjects;
    List<Rate_PHI__c> listOfOldratePhi = oldObjects;
    List<Rate_PHI__c> updatedList = new List<Rate_PHI__c>();
    Map<Id,Rate_PHI__c> mapOfRatePhi = new Map<Id,Rate_PHI__c>();
    //Set<ID> phiSet = new Set<ID>();
    for(Rate_PHI__c phi : listOfratePhi)
    {
        for(Rate_PHI__c oldPhi:listOfOldratePhi){
            if(oldPhi.Rate_Sync_Status__c!= UtilityConstant.SUCESS && phi.Rate_Sync_Status__c == UtilityConstant.SUCCESS)
            {  
             mapOfRatePhi.put(phi.id,phi);
             phi.Effective_Date__c = System.Now();
             phi.Version__c = System.today();
/*            }
            //updatedList.add(phi);
        }
    }
    if(mapOfRatePhi.size()>0){
        
        for(Rate_PHI__c ph:mapOfRatePhi.values()){
            ph.Effective_Date__c = System.Now();
            ph.Version__c = System.today();
            updatedList.add(ph);
        }
    }
    try
   {
     if(updatedList.size()>0)
     {
      update updatedList;
     }
   }
   Catch(Exception e)
   {
   }    
  } */
  
  
}