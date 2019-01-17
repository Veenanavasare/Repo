trigger SIVAR_UpdateEUTicket on IT_Support_Ticket__c (after insert) {
  
  
  
    Set<String> setITST = new Set<String>();
    List<End_User_Support_Ticket__c> updEUST = new List<End_User_Support_Ticket__c>();
    
    for(IT_Support_Ticket__c itst : Trigger.new)
    {
    setITST.add(itst.End_User_Support_Ticket__c);
    }
    
    List<End_User_Support_Ticket__c> est = [select Id,Status__c,End_User_Support_Ticket__c from End_User_Support_Ticket__c where End_User_Support_Ticket__c IN : setITST]; 
    
      for(IT_Support_Ticket__c itst : Trigger.new)
      {
      for(End_User_Support_Ticket__c eust : est)
      {
        if(eust.End_User_Support_Ticket__c == itst.End_User_Support_Ticket__c)
        {
        eust.IT_Support_Ticket__c = itst.Name;
        eust.Related_IT_Support_Ticket__c = itst.Id;
        eust.Status__c = 'Open (IT)';
        updEUST.add(eust);
        }
      }
      }
    
    if(SIVAR_itSupp.firstrun) 
    {
    update updEUST;
    SIVAR_itSupp.firstrun = false;
    }

  

}