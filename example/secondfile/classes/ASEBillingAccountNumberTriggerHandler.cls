public with sharing class ASEBillingAccountNumberTriggerHandler extends SITriggerOperations.SITriggerImpl{
    
    public boolean isExecuted;
    public ASEBillingAccountNumberTriggerHandler() 
    {
       isExecuted = true;
       
    }
    
    public override boolean onBeforeInsert(SObject[] newObjects) 
    {
     checkDuplicateName(newObjects, newObjects, true);
     return isExecuted;
    }
       public override boolean onAfterInsert(SObject[] newObjects) 
    {
       List<ASE_Billing_Account_Number__c> newObjList=newObjects;
       // updateASEProductOnAccount(newObjList[0].Account_Name__c);
        return true;
    }
    
    public override boolean onBeforeUpdate(SObject[] oldObjects,SObject[] newObjects,Map<Id,SObject> newObjectsMap )
    {
     checkDuplicateName(oldObjects, newObjects, false);
     return isExecuted;
    }
      public override boolean  onAfterUpdate(SObject[] oldObjects,SObject[] newObjects,Map<Id,SObject> newObjectsMap) 
    {
        List<ASE_Billing_Account_Number__c> newObjList=newObjects;
        updateASEProductOnAccount(newObjList[0].Account_Name__c);
        return true;        
    }
    public void checkDuplicateName(SObject[] oldObjects, SObject[] updatedObjects, boolean isInsert){
        List<ASE_Billing_Account_Number__c> newObjList = updatedObjects;
        List<ASE_Billing_Account_Number__c> oldObjList = oldObjects;
        Map<String,object> ASEMap = new Map<String,object>();
        List<String> nameStr = new List<String>();
        for(integer i=0;i<newObjList.size();i++){
            if(((newObjList[i].name != oldObjList[i].name || newObjList[i].Active__c != oldObjList[i].Active__c || newObjList[i].LATA__c != oldObjList[i].LATA__c) && newObjList[i].Active__c ) || (newObjList[i].Active__c == true && isInsert == true)){
                ASEMap.put(newObjList[i].Ban_LATA__c,newObjList[i]);
            }   
        }
        
        List<ASE_Billing_Account_Number__c> ASEBillingAccNumList = new List<ASE_Billing_Account_Number__c>();
        ASEBillingAccNumList = [Select Name, Account_Name__c, Active__c, LATA__c  from ASE_Billing_Account_Number__c WHERE Ban_LATA__c IN: ASEMap.keySet() AND Active__c =: true];
        
        for(ASE_Billing_Account_Number__c accNum: newObjList){
            if(ASEBillingAccNumList != null && ASEBillingAccNumList.size() > 0){
                accNum.addError('The BAN & LATA entered is already in the system, only unique BAN & LATA combinations are allowed.');     
            } 
        }
    }
      /*
    Added as part of Sprint-29 US780973
    */
    public void updateASEProductOnAccount(String accId)
    {
       
      Account currentAccount=[select No_Of_Active_BAN__c,No_Of_Active_CNM__c,ASE_ACNA__c,ASE_Ordering_Type__c,ASE_Product__c from Account where id=: accId];            

        if(currentAccount.ASE_Product__c  )
        {
        List<ASE_Billing_Account_Number__c> aseBillingAccountList=new List<ASE_Billing_Account_Number__c>();
             aseBillingAccountList= [Select Name, Account_Name__c, Active__c  from ASE_Billing_Account_Number__c WHERE Account_Name__c =: accId AND Active__c =: true];          
              if( aseBillingAccountList.size()== 0){
                currentAccount.ASE_Product__c=False;
                update currentAccount;
                }
        }
        
        
    }
}