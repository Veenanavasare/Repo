/* 
 Name: EUTktTriggerHandle r
 Type: Class 
 
 Description: 
 */ 
public with sharing class  EUTktTriggerHandler extends SITriggerOperations.SITriggerImpl{
    public boolean isExecuted ;

    // Default Constructor
/* 
 Name: EUTktTriggerHandler
 Description: 
 */ 
    public EUTktTriggerHandler (){
        isExecuted = true;
    }

    //An Overridden method for AfterInsert
/* 
 Name: onAfterInsert
 Description: 
 */ 
    public override boolean onAfterInsert(SObject[] newObjects) {
        try {
            createITSupportTkt(newObjects);
        } catch(Exception excep) {
            isExecuted = false;
            throw excep;
        }
        return isExecuted;
    }   

    //An Overridden method for AfterUpdate
/* 
 Name: onAfterUpdate
 Description: 
 */ 
    public override boolean onAfterUpdate(SObject[] oldObjects, SObject[] updatedObjects, Map<Id, SObject>  newObjectsMap) {
        try {
            createITSupportTkt(updatedObjects);
        } catch(Exception excep) {
            isExecuted = false;
            throw excep;
        }
        return isExecuted;
    }

    /* method to create IT Support ticket*/
    private void createITSupportTkt(SObject[] newObjects){
        End_User_Support_Ticket__c euTkt = null;
        List<End_User_Support_Ticket__c> euList= new List<End_User_Support_Ticket__c>();
        List<IT_Support_Ticket__c> itSupportTktList = new List<IT_Support_Ticket__c>();

        try{
            for(SObject s:newObjects){
                euTkt = (End_User_Support_Ticket__c)s;
                if((euTkt.Ticket_Type__c == UtilityConstant.BULKUPLOAD_REQUEST || euTkt.Ticket_Type__c == UtilityConstant.DEFECT) && (euTkt.IT_Support_Ticket__c == null ||euTkt.IT_Support_Ticket__c == SpecialCharacterConstant.CONCAT)){
                    itSupportTktList.add(generateITTicket(euTkt));
                }
                else if(euTkt.Ticket_Type__c == UtilityConstant.ENHANCEMENT && euTkt.Status__c == UtilityConstant.OPEN_IT_x && (euTkt.IT_Support_Ticket__c == null ||euTkt.IT_Support_Ticket__c == SpecialCharacterConstant.CONCAT)){
                //else if(euTkt.Ticket_Type__c == UtilityConstant.ENHANCEMENT && euTkt.Status__c == UtilityConstant.OPEN_IT_x){
                    itSupportTktList.add(generateITTicket(euTkt));
                }
            }
            if(!itSupportTktList.isEmpty()){
                insert itSupportTktList;
            }
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }

    /* This method will take End user ticket recrod as input and returns IT support ticket*/
    private IT_Support_Ticket__c generateITTicket(End_User_Support_Ticket__c euTkt){
        IT_Support_Ticket__c itSupportTkt = new IT_Support_Ticket__c();
        try{
            itSupportTkt.End_User_Support_Ticket__c = euTkt.name;
            itSupportTkt.Error_Message_Received__c = euTkt.Error_Message_Received__c;
            itSupportTkt.Impact__c = euTkt.Impact__c;
            itSupportTkt.Related_to__c = euTkt.Related_To__c;
            itSupportTkt.Severity__c = euTkt.Severity__c;
            itSupportTkt.Steps_to_Reproduce_Error__c = euTkt.Steps_to_Reproduce_Error__c;
            itSupportTkt.Ticket_Subject__c = euTkt.Subject__c;
            itSupportTkt.End_User_Support_Ticket__c = euTkt.End_User_Support_Ticket__c;
            itSupportTkt.Added_Screenshot_as_Note_Attachment__c = euTkt.Screen__c;
            itSupportTkt.Logged_Date_Time__c = system.now();
        }catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
        return itSupportTkt;
    }
}