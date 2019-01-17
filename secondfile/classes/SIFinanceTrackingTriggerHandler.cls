/*
    Author: Accenture IDC
    Project : SIVAR/Partner Exchange
    Requirement Number : R-2462 
    Requirement Description: 3rd Party Credit Check trigger handler class.
    Version:V1.0     Date : 28th January 2014
*/

public class SIFinanceTrackingTriggerHandler extends SITriggerOperations.SITriggerImpl{
	
	/*Global variables*/ 
	public boolean isExecuted ;

    /*Default cons*/
    public SIFinanceTrackingTriggerHandler() {
        isExecuted = true;
    }

    /*After update function*/
    public override boolean onAfterUpdate(SObject[] oldObjects, SObject[] updatedObjects, Map<Id, SObject>  newObjectsMap )  {
        try {
                updateTotalApprovedAmount(updatedObjects);
            }catch(Exception excep) {
            System.debug('Exception Caught :'+excep.getMessage());
            isExecuted = false;
            throw excep;
        }
        return isExecuted;
    }
    
    /* Business logic to update total aprroved amount on account.*/
    public void updateTotalApprovedAmount(SObject[] updatedObjects)
    {
        system.debug('Inside Trigger');
        list<Financing_history_tracking__c> fht =updatedObjects;
        Map<Id, Double> accMap = new Map<Id,Double>();
        list<Account> accList = null;
        list<Account> updateAccount = new list<Account>();
        
        AggregateResult[] groupedResults = [Select SUM(Approved_Amount__c), Account__c  From Financing_history_tracking__c  where  Approved_Amount__c!=null and Status__c='Approved'  GROUP BY  Account__c ];
        for(AggregateResult aresult : groupedResults)
        {
            accMap.put(String.valueOf(aresult.get('Account__c')),Double.valueOf(aresult.get('expr0')));
        }
        
        accList = [select Id, Total_Approved_Amount__c from Account where Id IN :accMap.keySet()];
        for(Account account :accList)
        {
                account.Total_Approved_Amount__c = accMap.get(account.Id);
                updateAccount.add(account);
        }
        if(updateAccount.size() > 0)
        {
            update updateAccount;
        }
        
    }
    
}