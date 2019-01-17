public with sharing class SIEndcustomerTriggerHandler extends SITriggerOperations.SITriggerImpl
{
    EmailTemplate notificationTamplate=[Select Subject,Name,Id,HtmlValue From EmailTemplate  where Name ='Named Endcustomer Creation Alert' limit 1] ;
    public List <Account_End_Customer_Junction__c> acctEndCustList=New List<Account_End_Customer_Junction__c>();
    Public List <User> usr= New List<User>(); 
    public set <Id> accoutOwners= New set <Id>();
    public String ownerNames='';
    public set <id> endCustnSet = New set <id>();
    public Map <Id,String> userMap= New Map <Id,String>();
    public Map<id,String> ownerMap= New Map<Id,String>();
    public List <End_Customer__c> ecListOld= New List<End_Customer__c>();
    public List <End_Customer__c> ecListNew= New List<End_Customer__c>();  
       
    public override boolean onAfterUpdate(SObject[] oldObjects, SObject[] updatedObjects, Map<Id, SObject>  newObjectsMap) 
    {
      validateUpdation(oldObjects,updatedObjects);
      UpdateCustomerDefiningGroup(updatedObjects);      
      return True;
    }
    
    public void validateUpdation(SObject[] oldObjects, SObject[] updatedObjects)
    {
        ecListOld=oldObjects;
        ecListNew=updatedObjects;
        for(integer i=0;i<ecListOld.size();i++)
        {
            if(ecListOld[i].Named_Account__c!=ecListNew[i].Named_Account__c)
            {
                endCustnSet.add(ecListOld[i].id);
            }
        }
        if( endCustnSet.size() > 0 ) {
            acctEndCustList=[SELECT Id,Account_Owner__c,End_Customer__c from Account_End_Customer_Junction__c Where End_Customer__c IN : endCustnSet];
            for(Account_End_Customer_Junction__c ae : acctEndCustList)
            {
                accoutOwners.add(ae.Account_Owner__c);
                if(!ownerMap.isEmpty())
                {
                    if(ownerMap.containsKey(ae.End_Customer__c))
                    {
                        ownerNames= ownerMap.get(ae.End_Customer__c);
                        ownerNames=ownerNames+','+ae.Account_Owner__c;
                        ownerMap.put(ae.End_Customer__c,ownerNames);
                    }
                    else
                    {
                        ownerMap.put(ae.End_Customer__c,ae.Account_Owner__c);
                    }
                }
                else
                {
                    ownerMap.put(ae.End_Customer__c,ae.Account_Owner__c);
                }           
            }
            if( accoutOwners.size() > 0 ) {
                usr = [Select Id,Email from User Where Id IN :accoutOwners];
                for(User us: usr)
                {
                    userMap.put(us.Id,us.email);
                }
            }
        }
            
        for(integer i=0;i<ecListOld.size();i++)
        {
          if(ecListOld[i].Named_Account__c!=ecListNew[i].Named_Account__c)
          {
            if(ecListNew[i].Named_Account__c==True)
            {   
                sendNotification(ecListNew[i],'Updated','to mark it as named end customer.');
            }
            else
            {
                sendNotification(ecListNew[i],'Updated','to make it as normal endcustomer.');
            }  
          }
      } 
    }
    public void sendNotification(End_customer__c endCust,String mailfor, String val)
    {
        
        String htmlEmailbody;
        List <String> emailAddress = New List<String>();
        List<String> ownerIds= New List <String>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();   
        String ownerNames = ownerMap.get(endCust.Id);
        if(ownerNames!=Null)
        {
        ownerIds = ownerNames.split(',',0);
        for(integer i=0; i< ownerIds.size();i++)
        {
            emailAddress.add(userMap.get(ownerIds[i]));
        }
        String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm() +'/' +endCust.Id;        
        mail.setToAddresses(emailAddress);
        mail.setSubject(notificationTamplate.Subject);
        htmlEmailbody = notificationTamplate.HtmlValue;
        htmlEmailbody = htmlEmailbody.replace('<![CDATA[', '');
        htmlEmailbody = htmlEmailbody.replace('{!End_Customer__c.Name}' , endCust.Name);
        htmlEmailbody = htmlEmailbody.replace('{!End_Customer__c.Link}' , fullFileURL);
        htmlEmailbody = htmlEmailbody.replace('{Action}',mailfor);
        htmlEmailbody = htmlEmailbody.replace('{text}',val);
        htmlEmailbody = htmlEmailbody.replace(']]>', '');
        mail.setHtmlBody(htmlEmailbody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        emailAddress.clear(); 
        ownerIds.clear();
        ownerNames=''; 
        }     
    } 
    
/*
     Update RDS-Deal Hash Fields with Values from Related Endcustomer's Junction Field Values
     Deal Hash :Customer Defining Group ID     
               
*/
   
    public void UpdateCustomerDefiningGroup(SObject[] updatedObjects)
    {
        List<End_Customer__c> ecUpdatedObject = updatedObjects;
        Set <ID> endCustomerIdSet = New set<Id>();
        Map<Id, Opportunity> OppEndCustMap = new Map<Id, Opportunity>();
        List<Deal_Hash__c> dhToUpdateObject = new List<Deal_Hash__c>();
                 
            for(End_Customer__c ec :ecUpdatedObject){
                if(ec.CDG__c != null){
                endCustomerIdSet.add(ec.Id);
                }
            }
        if( endCustomerIdSet.size() > 0 ) {    
        List<Opportunity> oppObject = [Select Id, End_Customer__c, End_Customer__r.CDG__c from Opportunity where End_Customer__c IN:endCustomerIdSet];
            for(Opportunity opp : oppObject){
                OppEndCustMap.put(opp.Id, opp);
            }
        if( OppEndCustMap.size() > 0 ) {
            List<Deal_Hash__c> dhObject = [Select Id, Name, Opportunity__c, Customer_Defining_Group_ID__c from Deal_Hash__c where Opportunity__c IN:OppEndCustMap.keySet()];
                for(Deal_Hash__c dhObj: dhObject){
                    if(dhObj.Customer_Defining_Group_ID__c == NULL){
                    dhObj.Customer_Defining_Group_ID__c = OppEndCustMap.get(dhObj.Opportunity__c).End_Customer__r.CDG__c;
                    dhToUpdateObject.add(dhObj);
                    }
                }
                try{
                update dhToUpdateObject;
                } catch(Exception ex){
                ex.getMessage();
                }
            }
        }
    }  
}