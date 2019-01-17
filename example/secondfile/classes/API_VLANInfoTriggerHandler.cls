/*
     Component Name :API_VLANInfoTriggerHandler 
     Requirement/User Story Number :US321961 
     Requirement Description:Update Record count of VLAN info records on RDS-Circuit and VLAN details
     Component Author:Accenture IDC
     Created Date:17th Sep 2014 
     Version:1.0
*/
    
public with sharing class API_VLANInfoTriggerHandler extends SITriggerOperations.SITriggerImpl{
    public override boolean onBeforeInsert (SObject[] newObjects)
    {
        try
        {         
       
          updateValidationFieldsOnInsertOfVLAN(newObjects);  
        }
        catch (exception e)
        {
           e.getMessage();
        }
        return true;
    } 
    // To be used for Future after insert operations 
    public override boolean onAfterInsert (SObject[] newObjects)
    {
        try
        {    
              CountRDSVLANInformation(newObjects);               
              updateValidationFieldsOnInsertOfVLAN(newObjects);        
        }
        catch (exception e)
        {
            e.getMessage();
        }
        return true;
    } 
     // To be used for Future After Update Operations 
    public override boolean onAfterUpdate(SObject[] oldObjects,SObject[] updatedObjects,Map<Id, SObject>  OldObjectsMap)
    {
        try
        {
              CountRDSVLANInformation(oldObjects);
        }
        catch (exception e)
        {
              e.getMessage();
        }
        return true;
    }
    // To be used for Future After Delete Operations 
    public override boolean onAfterDelete(SObject[] oldObjects,  Map<Id, SObject>  OldObjectsMap)
    {
        try
        {
          CountRDSVLANInformation(oldObjects); 
        }
        catch (exception e)
        {
              e.getMessage();
        }
        return true;
    }
 
 public void CountRDSVLANInformation(SObject[] newObjects){
      List<VLAN_Information__c> newlistOfCVLANInfo = newObjects;
      List<RDS_Premise_Details__c> listOfPremiseToBeupdated = new List<RDS_Premise_Details__c>();
      List<RDS_Premise_Details__c> listOfPremiseToBefetched = new List<RDS_Premise_Details__c>();       
      List<Circuit_and_VLAN_Details__c> cvlanList= new List<Circuit_and_VLAN_Details__c>(); 
      Set<Id> cvdIds = new Set<Id>();
      Set<Id> premIds = new Set<Id>();
      
      for(VLAN_Information__c vi : newlistOfCVLANInfo){
          if(vi.MACD_Type__c != 'D' && vi.MACD_Type__c != 'C'){
              cvdIds.add(vi.Circuit_and_VLAN_Details__c);
          }
      }
      
      if(cvdIds.size()>0){
      cvlanList =[Select Id,Premise__c,(select Id from VLAN_Information__r where Disconnected__c = false) from Circuit_and_VLAN_Details__c where Id IN :cvdIds ];
      }
      
      if(cvlanList.size()>0){
          for(Circuit_and_VLAN_Details__c cvlan: cvlanList){
               premIds.add(cvlan.Premise__c);    
          }
      }
      
      if(premIds.size()>0){
      listOfPremiseToBefetched =[select Id,USO_Number_of_USOS__c,USO_VLAN__c from RDS_Premise_Details__c where id IN :premIds ];         
      }
      
      if(listOfPremiseToBefetched.size()>0){
          for(RDS_Premise_Details__c pdet :listOfPremiseToBefetched )
          {
          if(pdet.USO_Number_of_USOS__c==0){
          pdet.USO_VLAN__c= 'N';
          }
              for(Circuit_and_VLAN_Details__c CVD: cvlanList)
              {
                  pdet.USO_Number_of_USOS__c = CVD.VLAN_Information__r.size();
                   if(pdet.USO_Number_of_USOS__c  > 0){
                        pdet.USO_VLAN__c = 'Y';
                     }
                    else if(pdet.USO_Number_of_USOS__c == 0 ){
                           pdet.USO_VLAN__c= 'N';
                    }
                  listOfPremiseToBeupdated.add(pdet);
              }
          }         
      }
      
      if(listOfPremiseToBeupdated.size()>0){
          try{
              update listOfPremiseToBeupdated;
          }
          catch(DMLException e){
              system.debug('exception here'+e);
          }
      }   
   } 

/*Method to update validation fields on Premise on after insert of VLAN Info*/
public void updateValidationFieldsOnInsertOfVLAN(SObject[] newObjects){
List<VLAN_Information__c> newlistOfCVLANInfo = newObjects;
List<Circuit_and_VLAN_Details__c> CVLANlist = new List<Circuit_and_VLAN_Details__c>();
List<RDS_Premise_Details__c> premiseList = new List<RDS_Premise_Details__c>();
List<VLAN_Information__c> vlanInfoList = new List<VLAN_Information__c> ();
List<RDS_Premise_Details__c> newPremiseToUpdate = new List<RDS_Premise_Details__c>();
map<Id, RDS_Premise_Details__c> PremiseMap = new map<id, RDS_Premise_Details__c>();
Set<ID>vlanSet = new Set<ID>();
Set<ID>CvlanSet = new Set<ID>();
Set<ID>cvlanIdSet = new Set<ID>();
decimal temp=0;

for(VLAN_Information__c vlanInfo:newlistOfCVLANInfo)
{  
    vlanSet.add(vlanInfo.Circuit_and_VLAN_Details__c);
    system.debug('***vlanSet:'+vlanSet.size());
}
if(vlanSet.size()>0)
{
    CVLANlist = [Select id,(select Id from VLAN_Information__r where Disconnected__c = false),Contracted_Port_Speed__c, Unilink_Indicator__c,Premise__c,Premise__r.MACD_Change_Type__c FROM Circuit_and_VLAN_Details__c WHERE id IN:vlanSet];
    system.debug('@@@CVLANlist:'+CVLANlist.size());
}
if(CVLANlist.size()>0)
{  
 for(Circuit_and_VLAN_Details__c cvlan:CVLANlist)
 {
     CvlanSet.add(cvlan.Premise__c);
     cvlanIdSet.add(cvlan.id);
      system.debug('$$$CvlanSet:'+CvlanSet.size());
 }
}
if(CvlanSet.size()>0 && cvlanIdSet.size()>0)
{
    premiseList = [Select id,Service_Type__c,Combined_VLAN_Speed__c,VLAN_Count__c,Product_Type__c,Unilink__c,Port_Speed__c,USO_Number_of_USOS__c  FROM RDS_Premise_Details__c WHERE id IN:CvlanSet];
    vlanInfoList = [Select id,VLAN_Premise_Number__c,Circuit_and_VLAN_Details__c,VLAN_Speed__c,VLANID__c,Disconnected__c FROM VLAN_Information__c WHERE Circuit_and_VLAN_Details__c IN:cvlanIdSet AND Disconnected__c = false];
    system.debug('%%%premiseList:'+premiseList.size());
}
if(premiseList.size()>0 && vlanInfoList.size()>0)
{
 for(RDS_Premise_Details__c premise:premiseList)
 { 
   temp = 0;
   for(Circuit_and_VLAN_Details__c cvlan:CVLANlist)
   {
      system.debug('---premise.id--'+premise.id);
      system.debug('---cvlan.Premise__c--'+cvlan.Premise__c);
      system.debug('---cvlan.id--'+cvlan.id);
    for(VLAN_Information__c vlanInfo:vlanInfoList)
    {  
     system.debug('---vlanInfo.Circuit_and_VLAN_Details__c--'+vlanInfo.Circuit_and_VLAN_Details__c);
    if(premise.id==cvlan.Premise__c){
    if(cvlan.id == vlanInfo.Circuit_and_VLAN_Details__c)
    {
     system.debug('-*-*-VLAN_Speed__c:'+vlanInfo.VLAN_Speed__c);
     temp = temp + decimal.valueOf(vlanInfo.VLAN_Speed__c);
     }
     system.debug('......temp:'+temp+'@@@cvlan.Premise__r.MACD_Change_Type__c'+cvlan.Premise__r.MACD_Change_Type__c);
     if(temp!=0 && (cvlan.Premise__r.MACD_Change_Type__c!='UBB Add' && cvlan.Premise__r.MACD_Change_Type__c!='UBB Change' && cvlan.Premise__r.MACD_Change_Type__c!='UBB Remove'))
       {
      premise.Port_Speed__c = cvlan.Contracted_Port_Speed__c;
      if(cvlan.Unilink_Indicator__c!=null || cvlan.Unilink_Indicator__c!=''){
      premise.Unilink__c =cvlan.Unilink_Indicator__c;
      }else{
      premise.Unilink__c='false';
      }
      premise.Product_Type__c = premise.Service_Type__c;
      premise.VLAN_Count__c = cvlan.VLAN_Information__r.size();
      premise.Combined_VLAN_Speed__c = temp;
      system.debug('---^^^^----'+vlanInfo.VLANID__c);
     //newPremiseToUpdate.add(premise);
      PremiseMap.put(premise.id,premise);
    }
    }
    }
    }
    }
    }
     if(PremiseMap.size()>0){
    try{
    //update newPremiseToUpdate;
    update PremiseMap.values();
    } catch(DMLException ex){
    ex.getmessage();
    }
    }
}

}