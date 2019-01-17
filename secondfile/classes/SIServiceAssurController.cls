/*
* Class Name:  SIServiceAssurController
* Author: Vijay
* Date: 03-MAY-2013
* Requirement #:R-2051
* Description:AJAX section to display when more information on a ticket record is requested.

*/
public class SIServiceAssurController {
    
    public SP_Account_Ticket__c accountTicket {get; set;}

    /*params Cons*/
    public SIServiceAssurController(ApexPages.StandardController controller) {
        accountTicket = (SP_Account_Ticket__c) controller.getRecord();
    }
    
    /*This method is used to talk to the service assurance system  -- ToDo in the future*/
    public void doFetchServiceAssurance() {
        ApexPages.Message errorInfoMsg = null;
        String castIronErrorMsg = '';
        
        try {
            //Write the code to talk the service assurance system
            castIronErrorMsg = SICastIronDelegate.doFetchSPAccountTicket(String.valueOf(accountTicket.Id));
            if(castIronErrorMsg.length() > 0) {
                errorInfoMsg = new ApexPages.Message(ApexPages.Severity.INFO, castIronErrorMsg);
                //errorInfoMsg = new ApexPages.Message(ApexPages.Severity.INFO, SIConstants.SER_ASS_ERROR_MSG);             
            } else {
                accountTicket = getUpdatedTicket();
            }
        } catch(Exception excep) {
            errorInfoMsg = new ApexPages.Message(ApexPages.Severity.ERROR, SIConstants.SER_ASS_ERROR_MSG);
        }
        if(null != errorInfoMsg) {
            ApexPages.addMessage(errorInfoMsg);
        }
   }
    /*getUpdatedTicket*/
   private SP_Account_Ticket__c getUpdatedTicket() {
        String query = 'SELECT ';
        String recordTypeName = [Select Name from RecordType Where 
            Id =: accountTicket.RecordTypeId LIMIT 1].get(0).Name;
        
        //for general
        for(Schema.FieldSetMember fieldObj : 
            SObjectType.SP_Account_Ticket__c.FieldSets.Service_Assurance.getFields()) {
            query += fieldObj.getFieldPath() + ', ';
        }
        
        //for AOTSCM
        if(recordTypeName.equalsIgnoreCase(SIConstants.SP_ACCOUNT_TICKET_RECORD_TYPES[0])) {
            for(Schema.FieldSetMember fieldObj : 
                SObjectType.SP_Account_Ticket__c.FieldSets.AOTSCM.getFields()) {
                query += fieldObj.getFieldPath() + ', ';
            }
        } else if (recordTypeName.equalsIgnoreCase(SIConstants.SP_ACCOUNT_TICKET_RECORD_TYPES[1])) {
            for(Schema.FieldSetMember fieldObj : 
                SObjectType.SP_Account_Ticket__c.FieldSets.AOTSTM.getFields()) {
                query += fieldObj.getFieldPath() + ', ';
            }
        } else if (recordTypeName.equalsIgnoreCase(SIConstants.SP_ACCOUNT_TICKET_RECORD_TYPES[2])) {
            for(Schema.FieldSetMember fieldObj : 
                SObjectType.SP_Account_Ticket__c.FieldSets.ISOM.getFields()) {
                query += fieldObj.getFieldPath() + ', ';
            }                   
        }  
        
        query += 'Id,RecordType.Name FROM SP_Account_Ticket__c Where Id=\'' + accountTicket.Id + '\' LIMIT 1';
        return Database.query(query);
   }
   
   /*Dynamic Apex to generate the Page Block Section*/
   public Component.Apex.PageBlockSection getPageBlockSection() {
        Component.Apex.PageBlockSection pgSec;
        String recordTypeName = '';
        List<Schema.FieldSetMember> fieldMemberList = new List<Schema.FieldSetMember>();
        Component.Apex.OutputField fieldDisplay = null;
        
        try {
            accountTicket = getUpdatedTicket();
            recordTypeName = accountTicket.RecordType.Name;
            
            if(null != recordTypeName && recordTypeName.length() > 0) {
                pgSec = new Component.Apex.PageBlockSection();
                pgSec.title =  recordTypeName + ' Ticket Info';
                pgSec.columns = 2;
                
                if(recordTypeName.equalsIgnoreCase(SIConstants.SP_ACCOUNT_TICKET_RECORD_TYPES[0])) {
                    fieldMemberList = SObjectType.SP_Account_Ticket__c.FieldSets.AOTSCM.getFields();
                } else if(recordTypeName.equalsIgnoreCase(SIConstants.SP_ACCOUNT_TICKET_RECORD_TYPES[1])) {
                    fieldMemberList = SObjectType.SP_Account_Ticket__c.FieldSets.AOTSTM.getFields();
                }  else if(recordTypeName.equalsIgnoreCase(SIConstants.SP_ACCOUNT_TICKET_RECORD_TYPES[2])) {                    
                    fieldMemberList = SObjectType.SP_Account_Ticket__c.FieldSets.ISOM.getFields();
                }
                
                for(Schema.FieldSetMember fieldMem : fieldMemberList) {
                    fieldDisplay  = new Component.Apex.OutputField();
                    fieldDisplay.expressions.value = '{!accountTicket.'+fieldMem.fieldPath+'}';
                    fieldDisplay.label = fieldMem.getLabel();
                    pgSec.childComponents.add(fieldDisplay);
                }
            }
            
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return pgSec;
   }
}