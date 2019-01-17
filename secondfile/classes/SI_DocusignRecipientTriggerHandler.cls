public class SI_DocusignRecipientTriggerHandler extends SITriggerOperations.SITriggerImpl
{    
    public override boolean onAfterUpdate(SObject[] oldObjects,SObject[] updatedObjects,Map<Id, SObject>  OldObjectsMap)
    {
        try{   
            updateDenialReasonOnQuote(oldObjects, updatedObjects);
        }
        catch (exception e){
            e.getMessage();
        }
        return true;
    }
  
    public void updateDenialReasonOnQuote(SObject[] oldObjects,SObject[] newObjects){
         List<dsfs__DocuSign_Recipient_Status__c> drsNewList=newObjects;
         List<dsfs__DocuSign_Recipient_Status__c> drsOldList=oldObjects;
         Set<String> docusignIds =new Set<String>();
         List<String> strlist = new List<String>();
         List<dsfs__DocuSign_Recipient_Status__c> drsList = new List<dsfs__DocuSign_Recipient_Status__c>();         
         List<Apttus_Proposal__Proposal__c> QuoteList = new List<Apttus_Proposal__Proposal__c>();
         List<Apttus_Proposal__Proposal__c> QuoteListUpdate = new List<Apttus_Proposal__Proposal__c>();
         
         for(integer i=0; i<drsNewList.size(); i++){               
            if( (drsOldList[i].CheckDenialReason__c != drsNewList[i].CheckDenialReason__c ) && drsNewList[i].CheckDenialReason__c == true )
            {
                docusignIds.add(drsNewList[i].dsfs__Envelope_Id__c);
                drsList.add(drsNewList[i]);
            }
        }
        
        QuoteList = [Select id,Docusign_Envelope__c from Apttus_Proposal__Proposal__c where Docusign_Envelope__c IN: docusignIds ];
        for(dsfs__DocuSign_Recipient_Status__c docStatus : drsList){            
            for(Apttus_Proposal__Proposal__c QuoList : QuoteList){
                if(QuoList.Docusign_Envelope__c == docStatus.dsfs__Envelope_Id__c){
                   if(docStatus.dsfs__Decline_Reason__c != null){
                       //QuoList.Denial_Reason__c = docStatus.dsfs__Decline_Reason__c; 
                       
                        String s1 = string.valueof(docStatus.dsfs__Decline_Reason__c);
                        String s2 = s1.unescapeHtml4();
                        strlist.add(s2);    
                        for(String str : strlist){
                            QuoList.Denial_Reason__c = str;   
                        }                      
                   }
                   QuoteListUpdate.add(QuoList);
                }
            }
        }
                
        if(QuoteListUpdate.size()>0 && QuoteListUpdate != null){
            database.update(QuoteListUpdate);
        }
    }
}