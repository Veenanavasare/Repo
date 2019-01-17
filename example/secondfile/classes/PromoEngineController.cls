/************************************************************************************
    @Author : Smarjit Debata
    @Company : Accenture Services Pvt. Ltd.
    @Email : smarjit.debata@accenture.com
    @Created Date : 01/August/2014
    @Description : Controller class of PromotionEngineCreationPage VF page.
    *************************************************************************************/
    public class PromoEngineController{
        
        public Promotion_Engine__c promoEngineDetails {get;set;}
        public List<WrapperRuleCriteriaData> lstRuleCriteria {get;set;}
        public List<SelectOption> lstInputFields {get;set;}
        public List<SelectOption> lstAjaxResponseInputFields {get;set;}
        public String ajaxParamId {get;set;}
        public String ajaxParamType {get;set;}
        Integer numbersOfCriteria = 3;
        public String usr {get; set;}
        
        /******************************************************************
        *
        *Constructor
        *
        *******************************************************************/
/* 
 Name: PromoEngineController
 Description: 
 */ 
        public PromoEngineController( ApexPages.StandardController stanC ){
            
            promoEngineDetails = new Promotion_Engine__c();
            lstRuleCriteria = new List<WrapperRuleCriteriaData>();
            lstInputFields = new List<SelectOption>();
            lstInputFields.add(new SelectOption(SIConstants.NONE,SIConstants.NONE));
            Integer percent;
            for( Integer i = 0; i < numbersOfCriteria; i++ ){
                lstRuleCriteria.add( new WrapperRuleCriteriaData( i, SIConstants.BLANKSPACE, createListOfTypes(), lstInputFields, createListOfOperators(),SIConstants.BLANKSPACE, createListOfConditionalOperators(),Dealregdecision(),percent ) );
            }
        }
        
        /******************************************************************
        *@Method Name : createListOfTypes
        *@Args : None
        *@Return : List<SelectOption>
        *******************************************************************/
/* 
 Name: createListOfTypes
 Description: 
 */ 
        public List<SelectOption> createListOfTypes(){
            
            try{
                List<SelectOption> listType = new List<SelectOption>();
                listType.add(new SelectOption(SIConstants.NONE, SIConstants.NONE));
                listType.add(new SelectOption(SIConstants.PERCENTAGE, SIConstants.PERCENTAGE));
                listType.add(new SelectOption(SIConstants.DATATYPE_NAME_STRING,SIConstants.DATATYPE_NAME_STRING));
                listType.add(new SelectOption(SIConstants.DATATYPE_NAME_PICKLIST,SIConstants.DATATYPE_NAME_PICKLIST));
                listType.add(new SelectOption(SIConstants.DATATYPE_NAME_DATE,SIConstants.DATATYPE_NAME_DATE));
                return listType;
            }catch(Exception ex){ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));return null;}
        }
        
        /******************************************************************
        *@Method Name : createListOfOperators
        *@Args : None
        *@Return : List<SelectOption>
        *******************************************************************/
/* 
 Name: createListOfOperators
 Description: 
 */ 
        public List<SelectOption> createListOfOperators(){
          try{   
            List<SelectOption> listOperators = new List<SelectOption>();
            listOperators.add(new SelectOption(SIConstants.NONE, SIConstants.NONE));
            Schema.DescribeFieldResult peDescribeResult = Promotion_Engine__c.Operator__c.getDescribe();
            List<Schema.PicklistEntry> pickListValues = peDescribeResult.getPicklistValues();
                
            for( Schema.PicklistEntry eachValue : pickListValues)
            {
                listOperators.add(new SelectOption(eachValue.getLabel(), eachValue.getValue()));
            }       
            return listOperators;
          }catch(Exception ex){ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));return null;}
        }
        
        /******************************************************************
        *@Method Name : createListOfConditionalOperators
        *@Args : None
        *@Return : List<SelectOption>
        *******************************************************************/
/* 
 Name: createListOfConditionalOperators
 Description: 
 */ 
        public List<SelectOption> createListOfConditionalOperators(){
         try{
            List<SelectOption> listConOperators = new List<SelectOption>();
            listConOperators.add(new SelectOption(SIConstants.NONE, SIConstants.NONE));
            Schema.DescribeFieldResult peDescribeResult = Criteria__c.And_Or__c.getDescribe();
            List<Schema.PicklistEntry> pickListValues = peDescribeResult.getPicklistValues();
            for( Schema.PicklistEntry eachValue : pickListValues)
            {
                listConOperators.add(new SelectOption(eachValue.getLabel(), eachValue.getValue()));
            }       
            return listConOperators;
           }catch(Exception ex){ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));return null;}  
        }
        /******************************************************************
        *@Method Name : Dealregdecision
        *@Args : None
        *@Return : List<SelectOption>
        *******************************************************************/
        public List<SelectOption> dealregdecision(){
         try{
            List<SelectOption> listdealregdecisions = new List<SelectOption>();
            listdealregdecisions.add(new SelectOption(SIConstants.NONE, SIConstants.NONE));
            Schema.DescribeFieldResult peDescribeResult1 = Criteria__c.Deal_Reg_Decision__c.getDescribe();
            List<Schema.PicklistEntry> pickListValues = peDescribeResult1.getPicklistValues();
            for( Schema.PicklistEntry eachValue1 : pickListValues)
            {
                listdealregdecisions.add(new SelectOption(eachValue1.getLabel(), eachValue1.getValue()));
            }       
            return listdealregdecisions;
          }catch(Exception ex){ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));return null;}  
        }
        /******************************************************************
        *@Method Name : createListInputFields
        *@Desc : Populates the input fields drop-down if a datatype is selected. 
        *@Args : None
        *@Return : List<SelectOption>
        *******************************************************************/
        public void createListInputFields(){
          try{
            List<Schema.FieldSetMember> peFSMember = SObjectType.Opportunity.FieldSets.Opty_Promo_Engine.getFields();
            List<Schema.FieldSetMember> peFSMember1 = SObjectType.Criteria__c.FieldSets.Criteria_Promo_Engine.getFields();

            lstAjaxResponseInputFields = new List<SelectOption>();
            if( ajaxParamType == SIConstants.PERCENTAGE ){
                lstAjaxResponseInputFields.clear();  
                lstAjaxResponseInputFields.add(new SelectOption(SIConstants.NONE, SIConstants.NONE));
                for( Schema.FieldSetMember fsItem : peFSMember ){ 
                    if( fsItem.getType() == Schema.DisplayType.Percent ){
                        lstAjaxResponseInputFields.add(new SelectOption(fsItem.getFieldPath(),fsItem.getLabel()));
                    }
                 } 
                 
            }
            else if( ajaxParamType == SIConstants.DATATYPE_NAME_STRING  ){
                 lstAjaxResponseInputFields.clear(); 
                 lstAjaxResponseInputFields.add(new SelectOption(SIConstants.NONE, SIConstants.NONE));
                 for( Schema.FieldSetMember fsItem : peFSMember ){
                    if(fsItem.getType() == Schema.DisplayType.String){
                        lstAjaxResponseInputFields.add(new SelectOption(fsItem.getFieldPath(),fsItem.getLabel()));
                    }
                 }
                 for( Schema.FieldSetMember fsItem1 : peFSMember1 ){
                    if(fsItem1.getType() == Schema.DisplayType.String){
                        lstAjaxResponseInputFields.add(new SelectOption(fsItem1.getFieldPath(),fsItem1.getLabel()));
                    }
                 }
            }
             else if( ajaxParamType == SIConstants.DATATYPE_NAME_PICKLIST ){
                 lstAjaxResponseInputFields.clear(); 
                 lstAjaxResponseInputFields.add(new SelectOption(SIConstants.NONE, SIConstants.NONE));
                 for( Schema.FieldSetMember fsItem1 : peFSMember1 ){
                    if(fsItem1.getType()==Schema.DisplayType.Picklist){
                        lstAjaxResponseInputFields.add(new SelectOption(fsItem1.getFieldPath(),fsItem1.getLabel()));
                    }
                 }
            }
            else if( ajaxParamType == SIConstants.DATATYPE_NAME_DATE ){
                 lstAjaxResponseInputFields.clear(); 
                 lstAjaxResponseInputFields.add(new SelectOption(SIConstants.NONE, SIConstants.NONE));
                 for( Schema.FieldSetMember fsItem1 : peFSMember1 ){
                    if(fsItem1.getType()==Schema.DisplayType.Date){
                        lstAjaxResponseInputFields.add(new SelectOption(fsItem1.getFieldPath(),fsItem1.getLabel()));
                    }
                 }
            }
            else{
                lstAjaxResponseInputFields.clear(); 
                lstAjaxResponseInputFields.add(new SelectOption(SIConstants.NONE, SIConstants.NONE));
            } 
            
            updateRuleCriteriaList();
           }catch(Exception ex){ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));}  
        }
        
        /******************************************************************
        *@InnerClass Name : updateRuleCriteriaList
        *@Desc : A wrapper to hold all the rule criteria.
        *******************************************************************/
/* 
 Name: WrapperRuleCriteriaData
 Type: Class 
 
 Description: 
 */ 
        public class WrapperRuleCriteriaData{
        
            public Integer itemId {get;set;}
            public String CriteriaName {get;set;}
            public List<SelectOption> listDataType {get;set;}
            public String selectedDataType {get;set;}
            public List<SelectOption> listFieldName {get;set;}
            public String selectedField {get;set;}
            public List<SelectOption> listOperator {get;set;}
            public String selectedOperator {get;set;}
            public String inputValue {get;set;}
            public Integer percent {get;set;}
            public List<SelectOption> listConditionalOperator {get;set;}
            public String selectedConOperator {get;set;}
            public List<SelectOption> listDealregdec {get;set;}
            public String selectedDealregdec {get;set;}
            
            
            
            
            
            /******************************************************************
            *Constructor
            *******************************************************************/
/* 
 Name: WrapperRuleCriteriaData
 Description: 
 */ 
            public WrapperRuleCriteriaData( Integer id, String name, List<SelectOption> types, List<SelectOption> inp, List<SelectOption> oprtr, String inpVal, List<SelectOption> conOprtr , List<SelectOption> dealregdec , Integer percnt  ){
                
                itemId = id;
                CriteriaName = name;
                listDataType = types;
                listFieldName = inp;
                listOperator = oprtr;
                inputValue = inpVal;
                percent = percnt;
                listConditionalOperator = conOprtr;
                listDealregdec = dealregdec;
            }
        
        }     
        
        /******************************************************************
        *@Method Name : updateRuleCriteriaList
        *@Desc : Refreshes the wrapper list when we select a datatype 
        *        in order to get the list of input fields 
        *@Args : None
        *@Return : List<SelectOption>
        *******************************************************************/
        public void updateRuleCriteriaList(){
         try{
            for( WrapperRuleCriteriaData ruleCriteriaItem : lstRuleCriteria ){
            
                if( String.valueOf(ruleCriteriaItem.itemId) == ajaxParamId ){
                    
                    ruleCriteriaItem.listFieldName = lstAjaxResponseInputFields;
                }    
            }
           }catch(Exception ex){ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));}
        }
        /******************************************************************
        *@Method Name : savePromotionAndCriteria
        *@Desc : Introduce the required Field types and displays error messages, Saving criteria and promotion Engine Object
        *@Args : None
        *******************************************************************/
        public pageReference savePromotionAndCriteria()
        {
          try{
            list<WrapperRuleCriteriaData> insertselectedRecords = new list<WrapperRuleCriteriaData>();
            if(promoEngineDetails.Activation_Date__c == null || promoEngineDetails.BCC_Code__c == null || promoEngineDetails.Discount_Percentage__c == null || promoEngineDetails.Expiration_Date__c == null || promoEngineDetails.Promotion_Name__c == null || promoEngineDetails.Rank__c == null || promoEngineDetails.Rule_Category__c == null || promoEngineDetails.Category_Order__c == null)
            {
                ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,SIConstants.ALL_REQUIRED_EXCEPT_CURRENTLYACTIVE_VFP);
                ApexPages.addMessage(errorMsg);
                return null;
            }
            List<User> usr = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
            if(usr[0].Profile.Name != SIConstants.System_Administrator){
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,SIConstants.SYS_ADMIN_ONLY);
            ApexPages.addMessage(errorMsg);
            return null;
            }
            Integer loopCounter = 0;
            String erroMsg = SpecialCharacterConstant.CONCAT;
            for( WrapperRuleCriteriaData criteriaRecs : lstRuleCriteria)
            {
                loopCounter++;
                Boolean flagIfPartiallyEmpty = false;
                if((criteriaRecs.CriteriaName != null && criteriaRecs.CriteriaName.length() != 0) && criteriaRecs.selectedDataType != SIConstants.NONE && criteriaRecs.selectedField != SIConstants.NONE && criteriaRecs.selectedOperator != SIConstants.NONE && ( criteriaRecs.inputValue != null && criteriaRecs.inputValue.length() != 0 ) && criteriaRecs.selectedConOperator != SIConstants.NONE )
                {
                    try{
                        if(criteriaRecs.selectedDataType== SIConstants.PERCENTAGE)
                        {
                            Decimal tempVar = Decimal.valueOf(criteriaRecs.inputValue);
                        }
                    }catch(Exception e)
                    {
                        ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,SIConstants.CHECK_INPUT_VALUES_ERROR);
                        ApexPages.addMessage(errorMsg);
                        return null;
                    }
                    if(criteriaRecs.selectedDataType== SIConstants.DATATYPE_NAME_STRING && (criteriaRecs.selectedOperator== SIConstants.LESSTHANOPERATOR||criteriaRecs.selectedOperator==SIConstants.GREATERTHANOPERATOR))
                    {
                        ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,SIConstants.STRING_DATA_TYPE_ERROR1);
                        ApexPages.addMessage(errorMsg);
                        return null;
                    } 
                    insertselectedRecords.add(criteriaRecs);
                }
                else {
                    flagIfPartiallyEmpty = checkRowValues(criteriaRecs);
                }
                
                if( flagIfPartiallyEmpty )
                {       
                    ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,SIConstants.ALL_INPUTS_REQUIRED_ERROR+loopCounter);
                    ApexPages.addMessage(errorMsg);
                    return null;
                }
                
            }
            if( insertselectedRecords.size() == 0 )
            {
                ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,SIConstants.ATLEAST_ONE_SHOULD_BE_ENTERED);
                ApexPages.addMessage(errorMsg);
                return null;
            }
            else
            {   
                try{     
                    insert promoEngineDetails;
                    Integer criteriaNum = 0;
                    list<Criteria__c> insertCriteriaRecs = new list<Criteria__c>();
                    for(WrapperRuleCriteriaData criteriaRecs : insertselectedRecords)
                    {
                        criteriaNum ++;
                        Criteria__c criteria = new Criteria__c();
                        criteria.Criteria_Name__c = criteriaRecs.CriteriaName;
                        criteria.Input_Data_Type__c = criteriaRecs.selectedDataType;
                        criteria.Input_Field__c = criteriaRecs.selectedField;
                        criteria.Operator__c = criteriaRecs.selectedOperator;
                        criteria.Promotion_Engine__c = promoEngineDetails.Id;
                        criteria.Value__c = criteriaRecs.inputValue;
                        criteria.Deal_Reg_Discount__c = criteriaRecs.percent;
                        criteria.And_Or__c = criteriaRecs.selectedConOperator;
                        criteria.Deal_Reg_Decision__c = criteriaRecs.selectedDealregdec;
                        criteria.CriteriaNumber__c=criteriaNum;
                        insertCriteriaRecs.add(criteria);
                        if(criteriaRecs.percent > 50 || criteriaRecs.percent < 0 )
                         {
                ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,SIConstants.DEAL_REG_DISCOUNT_RANGE);
                ApexPages.addMessage(errorMsg);
                return null;
                         }
                    }
                    
                        
                     
                    
                    if( insertCriteriaRecs != null )
                    {
                        insert insertCriteriaRecs;
                        Pagereference promEnginePage =  new Pagereference(label.PromtionEnginetTab);
                        promEnginePage.setRedirect(true);
                        return promEnginePage;
                    }
                }catch(Exception e)
                {
                    ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                }
            }
            return null;
           }catch(Exception ex){ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));return null;}
        }
        /******************************************************************
        *@Method Name : checkRowValues
        *@Desc : Flag Checks are done
        *@Args : None
        *******************************************************************/
        public Boolean checkRowValues(WrapperRuleCriteriaData criteriaRecs)
        {
          try{
            if((criteriaRecs.CriteriaName != null && criteriaRecs.CriteriaName.length() != 0) && criteriaRecs.selectedDataType != SIConstants.NONE && criteriaRecs.selectedField != SIConstants.NONE && criteriaRecs.selectedOperator != SIConstants.NONE && ( criteriaRecs.inputValue != null && criteriaRecs.inputValue.length() != 0 ) && criteriaRecs.selectedConOperator != SIConstants.NONE )
            {
                return false;
            }
            else
            {
                Boolean flagCheck = false;
                if(criteriaRecs.CriteriaName != null && criteriaRecs.CriteriaName.length() != 0 )
                {
                    flagCheck = true;
                }

                if(criteriaRecs.selectedDataType != UtilityConstant.NONE)
                {
                    flagCheck = true;
                }
                
                if(criteriaRecs.selectedField != UtilityConstant.NONE)
                {
                    flagCheck = true;
                }
                
                if(criteriaRecs.selectedOperator != UtilityConstant.NONE)
                {
                    flagCheck = true;
                }
                
                if(criteriaRecs.inputValue != null && criteriaRecs.inputValue.length() != 0  )
                {
                    flagCheck = true;
                }
                
                if(criteriaRecs.selectedConOperator != UtilityConstant.NONE)
                {
                    flagCheck = true;
                }
                return flagCheck;
                
            }
           }catch(Exception ex){ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));return null;}
        }
         /******************************************************************
        *@Method Name : cancelPromotion
        *@Desc : Cancel button page to be redirected
        *@Args : None
        *******************************************************************/
        public pageReference cancelPromotion()
        {
        try{
            Pagereference promEnginePage =  new Pagereference(label.PromtionEnginetTab);
            promEnginePage.setRedirect(true);
            return promEnginePage;
          }catch(Exception ex){ ATTException.logException( ex.getTypeName(), ATTException.constructExceptionMessageString(ex));return null;} 
                
        }
    }