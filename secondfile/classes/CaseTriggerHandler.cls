/***************************************************************************************** 
 Apex Class Name     : CaseTriggerHandler 
 Version             : 1.0 
 Created Date        : 13th June 2016
 Function            : Case Trigger Handler
*****************************************************************************************/
public with sharing class CaseTriggerHandler extends SITriggerOperations.SITriggerImpl {
    public boolean isExecuted ;
        
    public CaseTriggerHandler() {
        isExecuted = true;
    }
    
    public override boolean onBeforeInsert(sObject[] updatedObjects){
        calculateBusinessHoursAges(true,null,updatedObjects,null);
        throughChannelDataPopulation(updatedObjects);
        createWSLogsForThroughChannel(updatedObjects);
        return isExecuted;
    }
    
    public override boolean onBeforeUpdate(sObject[] oldObjects, sObject[] updatedObjects,Map<Id, sObject> oldObjectsMap) {
        calculateBusinessHoursAges(false,oldObjects,updatedObjects,oldObjectsMap);
        return isExecuted;
    }
    
    public void createWSLogsForThroughChannel(sObject[] newObjects){
        List<Case> newCaseList = newObjects;
        try{
            for (Case updatedCase : newCaseList) {
                if(updatedCase.Origin.startsWith('Through Channel')){
                    WebServiceLog__c wsLog = new WebServiceLog__c();
                    wsLog.WSLogTitle__c = 'Through Channel User Login failure';
                    if(updatedCase.Error__c != null){
                        wsLog.WSLog_error__c = String.valueOf(updatedCase.Error__c);
                    }
                    if(String.isNotBlank(updatedCase.Description)){
                        wsLog.Request_Data__c = updatedCase.Description;
                    }
                    if(String.isNotBlank(updatedCase.Error_Description__c)){
                        wsLog.Response_Data__c = updatedCase.Error_Description__c;
                    }
                    if(String.isNotBlank(updatedCase.Conversation_ID__c)){
                        wsLog.Conversation_Id__c = updatedCase.Conversation_ID__c;
                    }
                    if(String.isNotBlank(updatedCase.ContactId)){
                        wsLog.Contact_Id_WSLog__c = updatedCase.ContactId;
                    }
                    insert wsLog;
                }
            }
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    /*Logic to populate data for cases created for Through Channel*/
    public void throughChannelDataPopulation(sObject[] newObjects){
        List<Case> newCaseList = newObjects;
        Set<String> caseFederationIdSet= new Set<String>();
        Map<String,Case> contactIdToCaseMap = new Map<String,Case>();
        Map<String,Id> fedIdToContactIdMap = new Map<String,Id>();
        List<Contact> contactList = new List<Contact>();
        try{
            for(Case insertedCase : newCaseList) {                
                
                if(String.isNotBlank(insertedCase.Subject) && String.isNotBlank(insertedCase.Description) && (insertedCase.Subject.startsWith('2') || insertedCase.Subject.startsWith('[Stage TC]  2')) && String.isNotBlank(insertedCase.Origin) && insertedCase.Origin.startsWith('Through Channel')){
                    insertedCase.Origin = 'Through Channel User Login Failure';
                    if(insertedCase.Description.contains('Contact Name:') && insertedCase.Description.contains('Conversation ID') && String.isNotBlank(insertedCase.Description.substringBetween('Contact Name:','Conversation ID'))){
                        insertedCase.Federation_ID__c= insertedCase.Description.substringBetween('Contact Name:','Conversation ID').trim();
                    }
                    system.debug('@@@insertedCase.Description: '+insertedCase.Description);
                    if(insertedCase.Description.contains('Conversation ID:') && insertedCase.Description.contains('AT&T') && String.isNotBlank(insertedCase.Description.substringBetween('Conversation ID:','AT&T'))){
                        insertedCase.Conversation_ID__c = insertedCase.Description.substringBetween('Conversation ID:','AT&T').trim();
                        system.debug('@@@inside if');
                    }
                    else if(insertedCase.Description.contains('Conversation ID:') && insertedCase.Description.contains('____') && String.isNotBlank(insertedCase.Description.substringBetween('Conversation ID:','____'))){
                        insertedCase.Conversation_ID__c = insertedCase.Description.substringBetween('Conversation ID:','____').trim();
                        system.debug('@@@inside else 1');
                    }
                    else if(insertedCase.Description.contains('Conversation ID:') && String.isNotBlank(insertedCase.Description.substringAfter('Conversation ID:'))){
                        insertedCase.Conversation_ID__c = insertedCase.Description.substringBetween('Conversation ID:','');
                        system.debug('@@@inside else if 2');
                    }
                }
                
                if(String.isNotBlank(insertedCase.Origin) && insertedCase.Origin.startsWith('Through Channel') && String.isNotBlank(insertedCase.Subject)){
                    if(insertedCase.Subject.startsWith('1') || insertedCase.Subject.startsWith('[Stage TC]  1')){
                        insertedCase.Error__c = 1;
                    }else if(insertedCase.Subject.startsWith('2') || insertedCase.Subject.startsWith('[Stage TC]  2')){
                        insertedCase.Error__c = 2;
                    }
                    if(insertedCase.Subject.contains('-')){
                        insertedCase.Error_Description__c = insertedCase.Subject.substringAfter('-').trim();
                    }else {
                        insertedCase.Error_Description__c = insertedCase.Subject.trim();
                    }
                }
                
                if(String.isNotBlank(insertedCase.Federation_ID__c) && String.isNotBlank(insertedCase.Origin) && insertedCase.Origin.startsWith('Through Channel')){
                    caseFederationIdSet.add(insertedCase.Federation_ID__c);
                }
            }
            
            system.debug('caseFederationIdSet is '+caseFederationIdSet);
            if(!caseFederationIdSet.isEmpty()){
                contactList = [SELECT Id,Partner_Exchange_User_Name__c,Through_Channel_API_Message_Code__c, Through_Channel_API_Message__c FROM Contact WHERE Partner_Exchange_User_Name__c IN: caseFederationIdSet]; 
                for(Contact con : contactList){
                    fedIdToContactIdMap.put(con.Partner_Exchange_User_Name__c,con.Id);
                }
                for(Case caseToPopulateFedId : newCaseList){
                    if(String.isNotBlank(caseToPopulateFedId.Subject) && (caseToPopulateFedId.Subject.startsWith('2') ||  caseToPopulateFedId.Subject.startsWith('[Stage TC]  2'))){
                        contactIdToCaseMap.put(caseToPopulateFedId.Federation_ID__c,caseToPopulateFedId);
                        if(!fedIdToContactIdMap.isEmpty() && fedIdToContactIdMap.containsKey(caseToPopulateFedId.Federation_ID__c)){
                            caseToPopulateFedId.contactId = fedIdToContactIdMap.get(caseToPopulateFedId.Federation_ID__c);
                        }
                    }
                }
                if(contactList.size() > 0){
                    for(Contact con : contactList){
                        if(!contactIdToCaseMap.isEmpty()){
                            if(contactIdToCaseMap.containsKey(con.Partner_Exchange_User_Name__c)){
                                con.Through_Channel_API_Message_Code__c = String.valueOf(contactIdToCaseMap.get(con.Partner_Exchange_User_Name__c).Error__c);
                                con.Through_Channel_API_Message__c = contactIdToCaseMap.get(con.Partner_Exchange_User_Name__c).Error_Description__c;
                            }
                        }
                    }
                    update contactList;
                }
            }
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
    
    /*Logic to calculate the Business Hour Ages*/
    public void calculateBusinessHoursAges(Boolean isInsert,sObject[] oldObjects,sObject[] newObjects,Map<Id, sObject>  oldObjectsMap){
        system.debug('calling calculateBusinessHoursAges');
        List<Case> oldCaseList = oldObjects;
        List<Case> newCaseList = newObjects;
        if(isInsert) {
            for (Case updatedCase : newCaseList) {
                updatedCase.Last_Status_Change__c = System.now();
                updatedCase.Time_With_Customer__c = 0;
                updatedCase.Time_With_Support__c = 0;
                system.debug('updatedCase.Time_With_Support__c'+updatedCase.Time_With_Support__c);
            }
        }else {
            system.debug('inside update@@#@#@#@#@#@#');
            //Get the stop statuses
            Set<String> stopStatusSet = new Set<String>();
            for (Stop_Status__c stopStatus:[Select Name From Stop_Status__c]) {
                stopStatusSet.add(stopStatus.Name);
            }
    
            //Get the default business hours (we might need it)
            BusinessHours defaultHours = [select Id from BusinessHours where IsDefault=true];
    
            //Get the closed statuses (because at the point of this trigger Case.IsClosed won't be set yet)
            Set<String> closedStatusSet = new Set<String>();
            for (CaseStatus status:[Select MasterLabel From CaseStatus where IsClosed=true]) {
                closedStatusSet.add(status.MasterLabel);
            }
    
            //For any case where the status is changed, recalc the business hours in the buckets
            for (Case updatedCase:newCaseList) {
                Case oldCase = (Case)oldObjectsMap.get(updatedCase.Id);
                system.debug('old case is :: '+oldCase.Id);
                system.debug('old Status is :: '+oldCase.Status+' and new: '+updatedCase.Status);
                if (oldCase.Status!=updatedCase.Status && updatedCase.Last_Status_Change__c!=null) {
                    //OK, the status has changed
                    if (!oldCase.IsClosed) {
                        //We only update the buckets for open cases
    
                        //On the off-chance that the business hours on the case are null, use the default ones instead
                        Id hoursToUse = updatedCase.BusinessHoursId!=null?updatedCase.BusinessHoursId:defaultHours.Id;
    
                        //The diff method comes back in milliseconds, so we divide by 3600000 to get hours.
                        Double timeSinceLastStatus = BusinessHours.diff(hoursToUse, updatedCase.Last_Status_Change__c, System.now())/3600000.0;
                        System.debug(timeSinceLastStatus);
    
                        //We decide which bucket to add it to based on whether it was in a stop status before
                        if (stopStatusSet.contains(oldCase.Status)) {
                            updatedCase.Time_With_Customer__c += timeSinceLastStatus;
                        } else {
                            updatedCase.Time_With_Support__c += timeSinceLastStatus;
                        }
    
                        if (closedStatusSet.contains(updatedCase.Status)) {
                            updatedCase.Case_Age_In_Business_Hours__c = updatedCase.Time_With_Customer__c + updatedCase.Time_With_Support__c;
                        }
                    }
                    system.debug('updatedCase case is :: '+updatedCase);
                    updatedCase.Last_Status_Change__c = System.now();
                }
            }
        }
    }
}