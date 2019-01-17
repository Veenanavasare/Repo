public with sharing class ASEWholesaleContractNumberTriggerHandler extends SITriggerOperations.SITriggerImpl{

    public boolean isExecuted;
    public ASEWholesaleContractNumberTriggerHandler() 
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
       List<ASE_Wholesale_Contract_Number__c> newObjList=newObjects;
    //   updateASEProductOnAccount(newObjList[0].Account_Name__c);
        return true;
    }
    public override boolean onBeforeUpdate(SObject[] oldObjects,SObject[] newObjects,Map<Id,SObject> newObjectsMap )
    {
        checkDuplicateName(oldObjects, newObjects, false);
        return isExecuted;
    }
      public override boolean  onAfterUpdate(SObject[] oldObjects,SObject[] newObjects,Map<Id,SObject> newObjectsMap) 
    {
        List<ASE_Wholesale_Contract_Number__c> newObjList=newObjects;
        updateASEProductOnAccount(newObjList[0].Account_Name__c);
        return true;        
    }
    public void checkDuplicateName(SObject[] oldObjects, SObject[] updatedObjects, boolean isInsert){
        List<ASE_Wholesale_Contract_Number__c> newObjList = updatedObjects;
        List<ASE_Wholesale_Contract_Number__c> oldObjList = oldObjects;
        Map<String,object> ASEMap = new Map<String,object>();
        List<String> nameStr = new List<String>();
        for(integer i=0;i<newObjList.size();i++){
            if(((newObjList[i].name != oldObjList[i].name || newObjList[i].Active__c != oldObjList[i].Active__c) && newObjList[i].Active__c ) || (newObjList[i].Active__c && isInsert == true)){
                ASEMap.put(newObjList[i].name,newObjList[i]);
            }   
        }
        
        List<ASE_Wholesale_Contract_Number__c> ASEWholesaleContractNumList = new List<ASE_Wholesale_Contract_Number__c>();
        ASEWholesaleContractNumList = [Select Name, Account_Name__c, Active__c  from ASE_Wholesale_Contract_Number__c WHERE Name IN: ASEMap.keySet() AND Active__c =: true];
        
        for(ASE_Wholesale_Contract_Number__c ase: newObjList){
            if(ASEWholesaleContractNumList != null && ASEWholesaleContractNumList.size() > 0){
                ase.addError('The CNUM entered is already in the system, only unique CNUMs are allowed.');     
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
        List<ASE_Wholesale_Contract_Number__c> ASEWholesaleContractNumList =new List<ASE_Wholesale_Contract_Number__c>();
             ASEWholesaleContractNumList = [Select Name, Account_Name__c, Active__c  from ASE_Wholesale_Contract_Number__c WHERE Account_Name__c =: accId AND Active__c =: true];          
              if( ASEWholesaleContractNumList.size()== 0){
                currentAccount.ASE_Product__c=False;
                update currentAccount;
                }
        }
        
        
    }
}