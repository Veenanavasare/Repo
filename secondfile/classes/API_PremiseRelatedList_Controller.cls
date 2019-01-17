public Class API_PremiseRelatedList_Controller{

public List<RDS_Premise_Details__c> prlist{get;set;}
public List<Deal_Hash__c>dhlist = new List<Deal_Hash__c>();
public String RDSVersion {get;set;}
public String DhRecordId;
public String version;
public String dealname;
public String msg {get;set;}
public Boolean flagAll{get;set;}

    public API_PremiseRelatedList_Controller(ApexPages.StandardController controller) {
    DhRecordId=apexpages.currentpage().getparameters().get('id');
    dhlist = [Select id,Name,RDS_Version_Select__c from Deal_Hash__c where id=:DhRecordId];
    for(Deal_Hash__c dhrecord:dhlist)
    {
    version = dhrecord.RDS_Version_Select__c;
    dealname = dhrecord.Name;
    System.debug('@@@Version'+version );
        
    
        if(version=='ALL')
         {
            flagAll= true;
         }
    }
    if(version == null){
            System.debug('IN');
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select RDS Version to get the Premise Details.'); 
            ApexPages.addMessage(myMsg); 
        }
        else{
                if(flagAll== true)
                {
                   prlist = [Select id,DealHash__c,RDS_Version__c,Name,Premise_Number__c,GRID_Premise_ID__c,Service_Type__c,Transport_Type__c,Premise_Street_Number__c,Premise_Street_Name__c,Best_Available_Due_Date__c,Request_Due_Date__c FROM RDS_Premise_Details__c where DealHash__c=:DhRecordId order by RDS_Version__c asc];
                   system.debug('ALL works');
                }
                else
                {
                  prlist = [Select id,DealHash__c,RDS_Version__c,Name,Premise_Number__c,GRID_Premise_ID__c,Service_Type__c,Transport_Type__c,Premise_Street_Number__c,Premise_Street_Name__c,Best_Available_Due_Date__c,Request_Due_Date__c FROM RDS_Premise_Details__c WHERE RDS_Version__c=: decimal.valueOf(Version) AND DealHash__c=:DhRecordId]; 
                 system.debug('filter works');
                } 
               
               if(prlist.size()==0)
               {   system.debug('@@@@@@@'+prlist);
                   ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'No Matching Premise details found for the selected RDS Version'); 
                   ApexPages.addMessage(myMsg); 
               }
           }
}

public PageReference newRecord()
{
   PageReference newrec = new PageReference(Label.API_DealHashVersionDisplay1+'='+dealname+Label.API_DealHashVersionDisplay2+'='+DhRecordId+Label.API_DealHashVersionDisplay3+'='+DhRecordId);
    return newrec;

}
}