//A Contr oller class which deals with the SI Workflow rules
/* 
 Name: SIWorkflowController
 Type: Class 
 
 Description: 
 */ 
public with sharing class SIWorkflowController {
    
    public List<SelectOption> objectsList {get; set;}
    public List<SelectOption> dataTypeList {get; set;}
    public List<SelectOption> fieldsList {get; set;}
    public List<SelectOption> scoreFieldsList {get; set;}
    public List<sObject> NoofRulesentry{get; set;}
    public List<sObject> MaxOrderno{get; set;}
    public List<SelectOption> InPickList{get; set;}
    public List<SelectOption> OutPickList{get; set;}
    
    
    public WF_Engine_Rule__c wFRule;
    public List<WF_Engine_Rule__c> ReOrderRulesList{get; set;}
           
    public String RuleLabel{get;set;}
    public String RuleName{get;set;}
    public String selObjectName {get; set;}
    public String selDataTypeName {get; set;}
    public String selOutDataTypeName {get; set;}
    public String OutfieldName {get; set;}
    public String infieldName {get; set;}
    public String TypeValue {get; set;}
    public String OperatorValue{get;set;}
    public String rulecond{get;set;}
    public String rulescore{get;set;}
    public String InPickvalue{get;set;}
    public String OutPickvalue{get;set;}
    public Boolean isActive{get;set;}
    public Integer MaxOrder{get;set;}
    public Decimal OrderNum{get;set;}
    public Decimal temp1;
    
    WF_Engine_Rule__c temp;
    
    public Map<String, Schema.SObjectType> objectsMap = null;
    public Map<String, SIWorkflowObjectDto> objectsMapGUI = null;
    
    public String createType {get; set;}
    public PageReference pr {get; set;}
    
    //Default cons
/* 
 Name: SIWorkflowController
 Description: 
 */ 
    public SIWorkflowController(ApexPages.StandardController controller) {
    
        temp =(WF_Engine_Rule__c)controller.getrecord();
      
        if(temp.Id!=null){
         WFRule = [Select Id,Entry_Score__c,isActive__c,Order__c,Field_Name__c,DataType_Score__c,Output_DataType__c,Object_StoringOP__c,Object_TriggerRule__c,Operator__c,Score_Field__c,Score_Type__c,Score_Value__c,WFE_Rule_Name__c From WF_Engine_Rule__c  where Id=:temp.Id];
            
        
        RuleName=WFRule.WFE_Rule_Name__c;
        selObjectName=WFRule.Object_StoringOP__c;
        selObjectName=WFRule.Object_TriggerRule__c;
        selDataTypeName=WFRule.DataType_Score__c;
        selOutDataTypeName=WFRule.Output_DataType__c;
        isActive=WFRule.isActive__c;
        OperatorValue=WFRule.Operator__c;
        infieldName=WFRule.Field_Name__c;
        OutfieldName=WFRule.Score_Field__c;
        if(selDataTypeName==UtilityConstant.PICKLIST){
            InPickvalue=WFRule.Entry_Score__c;
            getInPicklistvalues();
        }
        else{
            rulecond=WFRule.Entry_Score__c;
        }
        if(selOutDataTypeName==UtilityConstant.PICKLIST){
            OutPickvalue=WFRule.Score_Value__c;
            getOutPicklistvalues();
        }
        else{
            rulescore=WFRule.Score_Value__c;
        }
        
        
        TypeValue=WFRule.Score_Type__c;
        OrderNum=WFRule.Order__c;
        
        MaxOrderno=[select Id from WF_Engine_Rule__c where Object_TriggerRule__c=:selObjectName];
        MaxOrder =MaxOrderno.size();
        
        
        
        }
        if(null == objectsList) {
            objectsList = getObjectNames();
        }
        if(null == dataTypeList) {
            dataTypeList = SIHelper.getInstance().getSortedDataTypes();
        }
       if(null == fieldsList) {
           getFieldsNames();
        }  
        if(null==NoofRulesentry){
           NoofRulesentry=[select id from Lead limit 1];
            }            
    }
    
    //Method returns the list of Objects in the organization
/* 
 Name: getObjectNames
 Description: 
 */ 
    public List<SelectOption> getObjectNames() {
        try {
            objectsMap = Schema.getGlobalDescribe();
            objectsMapGUI = new Map<String, SIWorkflowObjectDto>();        
            Schema.SObjectType sobjType = null;
            Schema.DescribeSObjectResult describeObjectRes = null;
            SIWorkflowObjectDto workflowObject = null;
            
            if(null != objectsMap && !objectsMap.isEmpty()) {
                for(String mapKey : objectsMap.keySet()) {
                    sobjType = objectsMap.get(mapKey);
                    describeObjectRes = sobjType.getDescribe();
                    
                    if(describeObjectRes.isQueryable() &&
                        describeObjectRes.isSearchable() && describeObjectRes.isUpdateable()
                        && describeObjectRes.isDeletable()) {
                        workflowObject = populateObjectFields(describeObjectRes);
                        objectsMapGUI.put(describeObjectRes.getLabel(),workflowObject);
                    }
                }
            }
            return SIHelper.getInstance().getSortedList(objectsMapGUI,true);            
        } catch(Exception excep ) {
            ATTException.logException( excep.getTypeName(), ATTException.constructExceptionMessageString(excep));
        }
        return null;
    }
    
    //Get fields Associated to an object
/* 
 Name: getFieldsNames
 Description: 
 */ 
    public PageReference getFieldsNames() {
        try {
            SIWorkflowObjectDto workflowDtoObj = objectsMapGUI.get(selObjectName);
            if(workflowDtoObj != null) {
                //fieldsList = SIHelper.getInstance().getSortedFieldsList(workflowDtoObj.allFieldsList, true);
                fieldsList = SIHelper.getInstance().getSortedFieldsList(workflowDtoObj.dataTypeFieldsMap.get(selDataTypeName), true,selObjectName);
                scoreFieldsList = SIHelper.getInstance().getSortedFieldsList(workflowDtoObj.dataTypeFieldsMap.get(selOutDataTypeName), true,selObjectName);
            } else {
                fieldsList = SIHelper.getInstance().getSortedFieldsList(null, true,selObjectName);
                scoreFieldsList = SIHelper.getInstance().getSortedFieldsList(null, true,selObjectName);
            }
            
            
        } catch(Exception excep) {
            ATTException.logException( excep.getTypeName(), ATTException.constructExceptionMessageString(excep));
        }
        return null;
    }
    
/* 
 Name: resetDatatype
 Description: 
 */ 
    public PageReference resetDatatype(){
        try{
        selDataTypeName=UtilityConstant.SIVARConst_NONE_x;
        selOutDataTypeName=UtilityConstant.SIVARConst_NONE_x;
        
        MaxOrderno=[select Id from WF_Engine_Rule__c where Object_TriggerRule__c=:selObjectName];
        MaxOrder =MaxOrderno.size();
        return null;
        
    }
    catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
return null;
}
}
    
     
    
    /*a method populates the fields based on the describesobjectresult*/
    private SIWorkflowObjectDto populateObjectFields(Schema.DescribeSObjectResult describeObjectRes) {
        try{
        SIWorkflowObjectDto workflowDtoObj = new SIWorkflowObjectDto(
            describeObjectRes.getLabel(),describeObjectRes.getName());
        
        Map<String, Schema.SObjectField> sobjectFieldsMap = describeObjectRes.fields.getMap();
        
        Schema.SObjectField sfieldType = null;
        Schema.DescribeFieldResult describeFieldRes = null;
        SIWorkflowObjectDto.SIWorkflowField workFlowFieldObj = null;
        Schema.DisplayType displayType = null;
        
        for(String keySet : sobjectFieldsMap.keySet()) {
            sfieldType = sobjectFieldsMap.get(keySet);
            describeFieldRes = sfieldType.getDescribe();
            workFlowFieldObj = new SIWorkflowObjectDto.SIWorkflowField(describeFieldRes.getLabel(), 
                describeFieldRes.getName(),'');
            workflowDtoObj.allFieldsList.add(workFlowFieldObj);
            
            displayType = describeFieldRes.getType();
            
            if(displayType == Schema.DisplayType.Boolean) {
                workFlowFieldObj.fieldDataType = 'Boolean';
                workflowDtoObj.dataTypeFieldsMap.get('Boolean').add(workFlowFieldObj);
            } else if(displayType == Schema.DisplayType.Double || 
                displayType == Schema.DisplayType.Integer) {
                workFlowFieldObj.fieldDataType = 'Number';
                workflowDtoObj.dataTypeFieldsMap.get('Number').add(workFlowFieldObj);   
            } else if(displayType == Schema.DisplayType.Email  || //|| displayType == Schema.DisplayType.Picklist
                displayType == Schema.DisplayType.Phone || displayType == Schema.DisplayType.String ||
                displayType == Schema.DisplayType.TextArea || displayType == Schema.DisplayType.URL) {
                workFlowFieldObj.fieldDataType = 'String';
                workflowDtoObj.dataTypeFieldsMap.get('String').add(workFlowFieldObj);
            }else if(displayType == Schema.DisplayType.Picklist) {
                workFlowFieldObj.fieldDataType = UtilityConstant.PICKLIST;
                workflowDtoObj.dataTypeFieldsMap.get('Picklist').add(workFlowFieldObj);
            }
            
            
            else if(displayType == Schema.DisplayType.Date || 
                displayType == Schema.DisplayType.DateTime) {
                workFlowFieldObj.fieldDataType = 'Date';
                workflowDtoObj.dataTypeFieldsMap.get('Date').add(workFlowFieldObj);     
            }
        }
        return workflowDtoObj;
    }
    catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
return null;
}
}
    
    /*getOperatorsymbels*/
public List<SelectOption> getOperatorsymbels()
  {
      try{
   List<SelectOption> operatorOptions = new List<SelectOption>();
    Schema.DescribeFieldResult subregion = Schema.sObjectType.WF_Engine_Rule__c.fields.Operator__c;
    List <Schema.PicklistEntry> pickValues = subregion.getPicklistValues();
    for(Schema.PicklistEntry pick: pickValues)
    {
      operatorOptions.add(new SelectOption(pick.getLabel(), pick.getValue()));
    }
    return operatorOptions;
  }
  catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
return null;
}
}
  /*getInPicklistvalues*/
 public Pagereference getInPicklistvalues()
  {
    try{
    String str=infieldName;
    String objectApiName=selObjectName;
    InPickList=new List<SelectOption>();
    
    if(objectApiName!=null && str!=null){
        SObject sobjectObj = ((Schema.SObjectType)Schema.getGlobalDescribe().get(objectApiName)).newSObject();
        InPickList = getPicklistValues(sobjectObj,str);
        //InPickList.add(new SelectOption(SpecialCharacterConstant.CONCAT, UtilityConstant.SIVARConst_NONE_x));
    }
    return null;
  }
  catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
return null;
}
}
  
  /*getOutPicklistvalues*/
  public List<SelectOption> getOutPicklistvalues()
  {
      try{
    String str=OutfieldName;
    String objectApiName=selObjectName;
    OutPickList=new List<SelectOption>();
    //OutPickList.add(new SelectOption(SpecialCharacterConstant.CONCAT, UtilityConstant.SIVARConst_NONE_x));
    if(objectApiName!=null && str!=null){
        SObject sobjectObj = ((Schema.SObjectType)Schema.getGlobalDescribe().get(objectApiName)).newSObject();
        OutPickList = getPicklistValues(sobjectObj,str);
    }
    return null;
  }
  catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
return null;
}
}
  /*getPicklistValues*/
  public list<SelectOption> getPicklistValues(SObject obj, String fld)
   {
       try{
      List<SelectOption> options = new list<SelectOption>();
      
      Schema.sObjectType objType = obj.getSObjectType();
      Schema.DescribeSObjectResult objDescribe = objType.getDescribe();       
      map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
      list<Schema.PicklistEntry> values =fieldMap.get(fld).getDescribe().getPickListValues();
      
      options.add(new SelectOption(SpecialCharacterConstant.CONCAT, UtilityConstant.SIVARConst_NONE_x));   
      for (Schema.PicklistEntry a : values)
      { 
         options.add(new SelectOption(a.getLabel(), a.getValue())); 
      }
      return options;
   }
   catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
return null;
}
}
  /*getScoretype*/
  public List<SelectOption> getScoretype()
  {
      try{
    List<SelectOption> scoretypeOptions = new List<SelectOption>();
    
    Schema.DescribeFieldResult subregion = Schema.sObjectType.WF_Engine_Rule__c.fields.Score_Type__c;
    List <Schema.PicklistEntry> pickValues = subregion.getPicklistValues();
    for(Schema.PicklistEntry pick: pickValues)
    {
      scoretypeOptions.add(new SelectOption(pick.getLabel(), pick.getValue()));
    }
    return scoretypeOptions;
  }
  catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
return null;
}
}
  /*Cancel*/
  public Pagereference cancel()
  {
      try{
     Pagereference wFRulesPage =  new Pagereference(Label.WF_Engine_Rules_Tab_Id);
    WFRulesPage.setRedirect(true);
    return WFRulesPage;
  }
  catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
return null;
}
}
  
  
  /*updateEFRules*/
  public Pagereference updateEFRules()
  { 
  try{
        
        if(selOutDataTypeName==null || OrderNum==null || OrderNum==0 ||  RuleName==null || selObjectName==null || selDataTypeName==null || infieldName==null || outFieldName==null){
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'All the Fields are Mandatory, Score fields should not be Zero');
             ApexPages.addMessage(errorMsg);
             OrderNum=null;
             return null;
        }
       else if(selDataTypeName==UtilityConstant.PICKLIST && (InPickvalue==null || InPickvalue==SpecialCharacterConstant.CONCAT)){      
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Picklist In Value should be Null and Picklist Should not be null');
            ApexPages.addMessage(errorMsg);
            return null;
       }else if(selDataTypeName==UtilityConstant.PICKLIST && (OperatorValue=='>' ||OperatorValue=='<' || OperatorValue=='>=' ||OperatorValue=='<=' ||OperatorValue==SpecialCharacterConstant.CURLYBRACKETS ||OperatorValue==SpecialCharacterConstant.NOTBRACES)){
             ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Picklist Datatype can only have ,=,!=');
             ApexPages.addMessage(errorMsg);
             return null;
       }
       else if(selOutDataTypeName==UtilityConstant.PICKLIST && (OutPickvalue==null || OutPickvalue==SpecialCharacterConstant.CONCAT)){
             ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Picklist Out Value should be Null and Picklist Should not be null');
             ApexPages.addMessage(errorMsg);
             return null;
       }
      else if(selDataTypeName=='String' && (OperatorValue=='>' ||OperatorValue=='<' || OperatorValue=='>=' ||OperatorValue=='<=')){
             ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'String Datatype can only have =,!=,{},!{}');
             ApexPages.addMessage(errorMsg);
             return null;
      }
      else if(selDataTypeName!=UtilityConstant.PICKLIST && (rulecond==null || rulecond==SpecialCharacterConstant.CONCAT)){
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'In Value Should Not be Null');
            ApexPages.addMessage(errorMsg);
            return null;
       }
      else if(selDataTypeName=='Number' && (OperatorValue==SpecialCharacterConstant.CURLYBRACKETS ||OperatorValue==SpecialCharacterConstant.NOTBRACES)){
             ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Number Datatype cant only have ,{},!{}');
             ApexPages.addMessage(errorMsg);
             return null;
             
      }       
     else if(selOutDataTypeName!='Number' && (TypeValue==UtilityConstant.SUBTRACT || TypeValue==UtilityConstant.ADD)){
             ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'String and Picklist Cant have Add and Subtract Operation');
             ApexPages.addMessage(errorMsg);
             return null;
     }else if(selOutDataTypeName!=UtilityConstant.PICKLIST && (rulescore==null || rulescore==SpecialCharacterConstant.CONCAT)){
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Out Value Should Not be Null');
            ApexPages.addMessage(errorMsg);
          return null;
     }
     else if(temp.id!=null && OrderNum>MaxOrder){
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Order No Should Less than or equal to '+MaxOrder);
            ApexPages.addMessage(errorMsg);
            return null;
     }
     else if(temp.id==null && OrderNum>(MaxOrder+1)){
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Order No should not be Greater than '+(MaxOrder+1));
            ApexPages.addMessage(errorMsg);
            return null;
    }
    else{
          try{
              if(selDataTypeName=='Number'){
               temp1=Decimal.valueOf(rulecond);
              }
              if(selOutDataTypeName=='Number'){
               temp1=Decimal.valueOf(rulescore);
              }
              if(selDataTypeName==UtilityConstant.PICKLIST){
                rulecond=InPickvalue;
               }
              if(selOutDataTypeName==UtilityConstant.PICKLIST){
                rulescore=OutPickvalue;
               }
           
          }catch(Exception e){
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please Check Input and Output values');
             ApexPages.addMessage(errorMsg);
             return null;
            
          }
           
           if(temp.id!=null){
                
                if(WFRule.Order__c>OrderNum){
                    ReOrderRulesList =[select id,Order__c from WF_Engine_Rule__c where Object_TriggerRule__c=:selObjectName and Order__c>=:OrderNum and Order__c<=:WFRule.Order__c and id!=:temp.id];
                    for (WF_Engine_Rule__c RO:ReOrderRulesList) {
                    RO.Order__c =RO.Order__c+1;
                    }
                }
                else if(WFRule.Order__c<OrderNum){
                    ReOrderRulesList =[select id,Order__c from WF_Engine_Rule__c where Object_TriggerRule__c=:selObjectName and Order__c<=:OrderNum and Order__c>=:WFRule.Order__c and id!=:temp.id];
                    for (WF_Engine_Rule__c RO:ReOrderRulesList) {
                    RO.Order__c =RO.Order__c-1; 
                    }
            }else{
                ReOrderRulesList =[select id,Order__c from WF_Engine_Rule__c where id!=:temp.id];
            }
            
                WFRule.WFE_Rule_Name__c=RuleName;
                WFRule.Object_StoringOP__c =selObjectName;
                WFRule.Object_TriggerRule__c=selObjectName;
                WFRule.Operator__c=OperatorValue;
                WFRule.Field_Name__c=infieldName;
                WFRule.Score_Field__c=OutfieldName;
                WFRule.Entry_Score__c=rulecond;
                //WFRule.Score_Value__c=InPickvalue;//
                WFRule.Score_Value__c=rulescore;
                WFRule.DataType_Score__c=selDataTypeName;
                WFRule.Output_DataType__c=selOutDataTypeName;
                WFRule.Score_Type__c=TypeValue;
                WFRule.IsActive__c=isActive;
                WFRule.Order__c=OrderNum;
                update WFRule;
                RuleLabel=null;
                RuleName=null;
           }
           else{
            
                ReOrderRulesList =[select id,Order__c from WF_Engine_Rule__c where Object_TriggerRule__c=:selObjectName and Order__c>=:OrderNum];
                WF_Engine_Rule__c wFEngine=new WF_Engine_Rule__c();
                //WFEngine.WFE_Rule_Label__c=RuleLabel;
                WFEngine.WFE_Rule_Name__c=RuleName;
                WFEngine.Object_StoringOP__c =selObjectName;
                WFEngine.Object_TriggerRule__c=selObjectName;
                WFEngine.Operator__c=OperatorValue;
                WFEngine.Field_Name__c=infieldName;
                WFEngine.Score_Field__c=OutfieldName;
                WFEngine.Entry_Score__c=rulecond;
                WFEngine.Score_Value__c=rulescore;
                WFEngine.DataType_Score__c=selDataTypeName;
                WFEngine.Output_DataType__c=selOutDataTypeName;
                WFEngine.Score_Type__c=TypeValue;
                WFEngine.IsActive__c=isActive;
                WFEngine.Order__c=OrderNum;
                insert WFEngine;
                RuleLabel=null;
                RuleName=null;
                
                for (WF_Engine_Rule__c RO:ReOrderRulesList) {
                    RO.Order__c =RO.Order__c+1;
                }
           }
        
        if(ReOrderRulesList.size()>0){
             update ReOrderRulesList;
        }
    
       Pagereference wFEnginePage =  new Pagereference('/apex/SIWorkflowDesigner');
       WFEnginePage.setRedirect(true);
       Pagereference wFRulesPage =  new Pagereference(Label.WF_Engine_Rules_Tab_Id);
       WFRulesPage.setRedirect(true);
       createtype = ApexPages.currentPage().getParameters().get('createtype');
        
       pr = (createtype=='create') ? WFRulesPage : WFEnginePage;
       return pr;
    }
  }
  catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
return null;
}
}
  
}