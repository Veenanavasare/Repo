public class SIVAR_WFEngineDelete {
    
    public WF_Engine_Rule__c WFRule;
    public String SuccessMsg{get;set;}
     public List<WF_Engine_Rule__c> ReOrderRulesList;
    
    public SIVAR_WFEngineDelete(ApexPages.StandardController controller) {
    
     WF_Engine_Rule__c  temp =(WF_Engine_Rule__c)controller.getrecord();
    
        if(temp.Id!=null){
         WFRule = [Select Id,Order__c,Object_TriggerRule__c From WF_Engine_Rule__c  where Id=:temp.Id];
         SuccessMsg='Please Click on the Delete Rule Button to Re-Order and Delete the Rule';
        }
     }
     
      public pagereference DeleteRule(){
        
        ReOrderRulesList =[select id,Order__c from WF_Engine_Rule__c where Object_TriggerRule__c=:WFRule.Object_TriggerRule__c and Order__c>=:WFRule.Order__c and Id!=:WFRule.Id];
        
         for (WF_Engine_Rule__c RO:ReOrderRulesList) {
                    RO.Order__c =RO.Order__c-1;
        }
        delete WFRule;
        Database.emptyRecycleBin(WFRule);
        update ReOrderRulesList;
        Pagereference WFRulesPage =  new Pagereference(Label.WF_Engine_Rules_Tab_Id);
        WFRulesPage.setRedirect(true);
        return WFRulesPage;
     }

}