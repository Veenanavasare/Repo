/*************************************************************************************************** 
 Trigger Name        : createITSTicketForFailedSites
 Version             : 1.0
 Created Date        : 7th Nov 2017
 Created By          : Bhupesh Kumar
 Description         : This class is a generic class to create ITS ticket for the failed sites after 3rd retrigger failure.
 Modified By         : 
 Modified Date       : 
***************************************************************************************************/

public with sharing class createITSTicketForFailedSites {
    
    public static void createITSTickets(set<Id> failedCustomerSiteIds){ 
        
        system.debug('====inside ITS ticket creation class==='+failedCustomerSiteIds);
        
        final string RELATED_TO = 'SI/VAR-API';
        final string TKT_SUBJECT = 'API Failure due to service unavailable';
        final string SEVERITY = '2 - High';
        final string IMPACT = 'API Call Failed Due to Service Unavailable, User is unable to continue in portal for this order and potentially others';
        
        list<IT_Support_Ticket__c> lstItSupportTickets = new list<IT_Support_Ticket__c>();
        
        try{
            if(!failedCustomerSiteIds.isEmpty()) {
                
                //*********** new logic to change the record owner *******************
                Set<Id> parentQuoteIds = new Set<Id>();
            
                map<Id, AT_T_Customer_Site_Quote__c> jnSiteQuoteMap = 
                new map<Id, AT_T_Customer_Site_Quote__c>([SELECT Id, AT_T_Customer_Site__c, AT_T_Quote__c 
                                                          FROM AT_T_Customer_Site_Quote__c 
                                                          WHERE AT_T_Customer_Site__c IN: failedCustomerSiteIds]);
                                                          
                if(!jnSiteQuoteMap.isEmpty()) {
                    for(AT_T_Customer_Site_Quote__c jnSiteQuote : jnSiteQuoteMap.values()){
                        parentQuoteIds.add(jnSiteQuote.AT_T_Quote__c);
                    }
                }  
                
                string quoteOwnerId = '';
                
                if(!parentQuoteIds.isEmpty()){
                    
                    quoteOwnerId = [SELECT Id,ownerId
                                    FROM Apttus_Proposal__Proposal__c
                                    WHERE Id IN : parentQuoteIds limit 1].ownerId;
                                    
                    // The above list will always have only 1 quote.
                
                }
                
                system.debug('===quoteOwnerId==='+quoteOwnerId);
                                                                                         
                //*********** End of New Logic ***************************************                                      
                                     
                list<CustomerSite__c> lstFailedCustomerSite = [SELECT Id,Name,ownerId
                                                               FROM CustomerSite__c
                                                               WHERE Id IN : failedCustomerSiteIds];                                                     
                                                               
                for(CustomerSite__c cSites : lstFailedCustomerSite) {
                    
                    IT_Support_Ticket__c itSupportObj = new IT_Support_Ticket__c();
                    itSupportObj.Related_to__c = RELATED_TO;
                    itSupportObj.Ticket_Subject__c = TKT_SUBJECT;
                    itSupportObj.Severity__c = SEVERITY;
                    itSupportObj.Logged_Date_Time__c = system.now();
                    itSupportObj.Impact__c = IMPACT;
                    itSupportObj.Status__c = Constant.Status_Open;
                    
                    itSupportObj.Steps_to_Reproduce_Error__c = 'Customer Site '+ cSites.Name +' is receiving API failure due to Service being Unavailable for one or more APIs in the system. SP User has tried multiple time to retrigger API in the system.'+'\n'+'Please investigate '+cSites.Name;
                    itSupportObj.Related_Customer_Site__c = cSites.id;
                    itSupportObj.OwnerId = quoteOwnerId;
                    
                    lstItSupportTickets.add(itSupportObj);
                }                                               
            }
            
            if(!lstItSupportTickets.isEmpty()){
                insert lstItSupportTickets;
                
                system.debug('====inside ITS ticket creation class insertion successful==='+lstItSupportTickets);
            }
        }
        catch(exception excep){
            system.debug('===Exception in ITS creation==='+excep.getMessage()+' at line no '+excep.getLineNumber());
        }
    }
    
    @InvocableMethod 
    public static void createITSTicketForQuoteStateFailure( List<Apttus_Proposal__Proposal__c> proposalList){
        System.debug('@@@@@@inside createITSTicketForQuoteStateFailure');
        final string RELATED_TO = 'SI/VAR - API';
        final string SEVERITY = '2 - High';
        final string IMPACT = 'System will not be able to process the request to create quote with or without registration or submit a quote for registration because of this error.';
        
        Set<Id> quoteIDs = new Set<Id>();
        
        if(!proposalList.isEmpty()){
            for(Apttus_Proposal__Proposal__c quote : proposalList){
                quoteIDs.add(quote.Id);
            }
        }
        System.debug('quoteids '+quoteIDs);
        String quoteOwnerId=' ';
        if(!quoteIDs.isEmpty()){
            quoteOwnerId = [SELECT Id,ownerId FROM Apttus_Proposal__Proposal__c WHERE Id IN : quoteIDs limit 1].ownerId;
            
        }
        list<IT_Support_Ticket__c> lstItSupportTickets = new list<IT_Support_Ticket__c>();
        
        for(Apttus_Proposal__Proposal__c quoteObj : proposalList) {
            IT_Support_Ticket__c itSupportObj = new IT_Support_Ticket__c();
            itSupportObj.Related_to__c = RELATED_TO;
            itSupportObj.Ticket_Subject__c = 'Create Quote – QuoteId:'+'  '+quoteObj.Name+' '+'Quote State updated to Failure';
            itSupportObj.Severity__c = SEVERITY;
            itSupportObj.Logged_Date_Time__c = system.now();
            itSupportObj.Impact__c = IMPACT;
            itSupportObj.Status__c = Constant.Status_Open;
            itSupportObj.Steps_to_Reproduce_Error__c = 'Create Quote -> QuoteId:'+'  '+quoteObj.Name+' '+'Quote State updated to Failure after quote is created.';
            itSupportObj.OwnerId = quoteOwnerId;
            lstItSupportTickets.add(itSupportObj);
        }   

        if(!lstItSupportTickets.isEmpty()){
                insert lstItSupportTickets;
                
                system.debug('====it support tickets insertion successful==='+lstItSupportTickets);
            }
        
        
        
        
        
    }
}