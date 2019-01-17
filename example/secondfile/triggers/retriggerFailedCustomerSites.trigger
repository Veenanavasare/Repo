/*************************************************************************************************** 
 Trigger Name        : retriggerFailedCustomerSites
 Version             : 1.0
 Created Date        : 2nd Nov 2017
 Created By          : Bhupesh Kumar
 Description         : Retrigger the failed Customer Sites upto 3 times.
 Modified By         : 
 Modified Date       : 
***************************************************************************************************/

trigger retriggerFailedCustomerSites on CustomerSite__c (before insert, before update) {
    
    Set<Id> failedCustomerSiteIds = new Set<Id>();
    Set<Id> failedCustomerSiteIdsForAPIMACD = new Set<Id>();
    set<Id> thirdRetriggerFailedIds = new set<Id>();
    
    if(Trigger.isInsert && Trigger.isBefore) {
        for(CustomerSite__c customerSitesObj : trigger.new) {
            customerSitesObj.Site_Failed_Counter__c = 0; 
            if(customerSitesObj.Site_Failed_Counter__c == NULL) {
                customerSitesObj.Site_Failed_Counter__c = 0; 
                system.debug('===Site Failed Counter after assigning==='+customerSitesObj.Site_Failed_Counter__c);
            }
        }
    }
    else if(Trigger.isUpdate && Trigger.isBefore) {
        for(CustomerSite__c customerSitesObj : trigger.new) {
            if(customerSitesObj.Has_Failed_Request__c == true){
                if(customerSitesObj.Site_Failed_Counter__c == NULL) {
                    customerSitesObj.Site_Failed_Counter__c = 0; 
                    system.debug('===Site Failed Counter after assigning==='+customerSitesObj.Site_Failed_Counter__c);
                }
                else if(customerSitesObj.Site_Failed_Counter__c != NULL){
                    customerSitesObj.Site_Failed_Counter__c = customerSitesObj.Site_Failed_Counter__c + 1;
                    system.debug('===Site Failed Counter inside loop trigger==='+customerSitesObj.Site_Failed_Counter__c);
                }
            }
            else if(customerSitesObj.Has_Failed_Request__c == false){
                customerSitesObj.Site_Failed_Counter__c = 0; 
            }
        }
    }
}