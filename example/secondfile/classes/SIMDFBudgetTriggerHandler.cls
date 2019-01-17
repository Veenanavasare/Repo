public class SIMDFBudgetTriggerHandler extends SITriggerOperations.SITriggerImpl {
    public boolean isExecuted ;

    //Default cons
    public SIMDFBudgetTriggerHandler() {
        isExecuted = true;
    }
    
    //an overriden method - before insert
    public  override boolean onBeforeInsert(SObject[] newObjects) {
        try {
            doCheckDuplicateMDFBudget(newObjects);
        } catch(Exception excep) {
            System.debug('Exception Caught :'+excep.getMessage());
            isExecuted = false;
            newObjects.clear();
            throw excep;
        }
        return isExecuted;
    }
    
    //An Overridden method
    public override boolean onBeforeUpdate(SObject[] oldObjects,SObject[] newObjects,Map<Id,SObject> newObjectsMap ){
        try{
            doCheckDuplicateMDFBudget(newObjects);
        }
        catch(Exception e){
            System.Debug('Exception here:'+e.getMessage());
            isExecuted=false;
            throw e;
        }
        return isExecuted;    
    } 
    
    //A method used to check for the duplicates
    private void doCheckDuplicateMDFBudget(SObject[] objectArr) {
        Set<Id> accountSet = new Set<Id>();
        Set<String> mdfYearSet = new Set<String>();
        Set<String> mdfQuarterSet = new Set<String>();
        Set<String> combinedStrSet = new Set<String>(); //account+year+quarter
        Map<String, SObject> objectsMap = new Map<String, SObject>();
        
        Id mdfBudgetAccount = null;
        String mdfBudgetQuarter = '';
        String mdfBudgetYear = '';
        String combinedStr = '';
                
        //a block to get the account, year and quarter
        for(SObject mdfBudget : objectArr) {
            mdfBudgetAccount = (Id) mdfBudget.get('Account__c');
            mdfBudgetQuarter = (String) mdfBudget.get('Quarter__c');
            mdfBudgetYear = (String) mdfBudget.get('MDF_Year__c');
            
            if(mdfBudgetAccount != null && mdfBudgetYear != null 
                && mdfBudgetQuarter != null) {
                accountSet.add(mdfBudgetAccount);
                mdfQuarterSet.add(mdfBudgetQuarter);
                mdfYearSet.add(mdfBudgetYear);
                combinedStr = mdfBudgetAccount+'|'+mdfBudgetYear+'|'+mdfBudgetQuarter;
                combinedStrSet.add(combinedStr);
                objectsMap.put(combinedStr, mdfBudget);
            }
        }

        //a block to query the records      
        if(!objectsMap.isEmpty()) {
            for(MDF_Budget__c mdfBudget : [Select Id,Account__c, Quarter__c, MDF_Year__c 
                from MDF_Budget__c Where Account__c IN :accountSet and Quarter__c IN :mdfQuarterSet and 
                MDF_Year__c IN :mdfYearSet]) {
                combinedStr = mdfBudget.Account__c+'|'+mdfBudget.MDF_Year__c+'|'+mdfBudget.Quarter__c;
                if(objectsMap.containsKey(combinedStr)) {
                    objectsMap.get(combinedStr).addError(SIConstants.MDF_REQ_EXISTS_MSG);
                }   
            }
        }
    } 
}