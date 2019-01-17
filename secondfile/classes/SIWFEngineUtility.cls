/* 
 Name:  SIWFEngineUtility
 Type: Class 
 Description: 
 */ 
public class SIWFEngineUtility {
    
    public static SIWFEngineUtility sIWFEngineUtilityobj = null;
    List<sObject> NewList {get; set;}
    List<sObject> OldList {get; set;}
    /*SIWFEngineUtility*/
     private SIWFEngineUtility() {}
    
/* 
 Name: getInstance
 Description: 
 */ 
    public static SIWFEngineUtility getInstance() {
        try{
        if(SIWFEngineUtilityobj == null) {
            SIWFEngineUtilityobj = new SIWFEngineUtility();
        }
        return SIWFEngineUtilityobj;
    }
    catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
return null;
}
}
    
/* 
 Name: Rulescoringengine
 Description: 
 */ 
    public List<sObject> rulescoringengine(String arg1,String arg2,SObject[] oldObjects, SObject[] updatedObjects){
        try{
        String obj=arg1;
        String event=arg2;
                
        NewList =updatedObjects;
        OldList =oldObjects;
                        
            List<WF_Engine_Rule__c> ruleList = new List<WF_Engine_Rule__c>();
            
            RuleList =[select id,Output_DataType__c,DataType_Score__c,field_name__c,score_field__c,Score_Type__c,Operator__c,operator_formula__c,entry_score__c,Score_Value__c from WF_Engine_Rule__c where Object_TriggerRule__c=:obj and IsActive__c=true order by Order__c desc];
            
            List<String> fieldInputList = new String[5]; //Rule fields names
            List<Decimal> numberInputList = new Decimal[3]; //Rule score and comparison values
            
            for(Integer a=0;a<NewList.size();a++){
                //0 = '>',1 = '<',2 = SpecialCharacterUtilityConstant.EQUAL
                
            //grabbing Rule logic and adding it to the Lists
            for(WF_Engine_Rule__c rule : RuleList){
                fieldInputList[0]= rule.field_name__c;
                fieldInputList[1]= rule.score_field__c;
                fieldInputList[2] = rule.Score_Type__c;
                numberInputList[0]= rule.operator_formula__c;
                
                if(rule.DataType_Score__c==UtilityConstant.STATIC_STRING ||rule.DataType_Score__c==UtilityConstant.PICKLIST ){
                    fieldInputList[3]=rule.entry_score__c;
                }   
                else{
                    numberInputList[1]= Decimal.valueOf(rule.entry_score__c);
                }
                if(rule.Output_DataType__c==UtilityConstant.STATIC_STRING || rule.Output_DataType__c==UtilityConstant.PICKLIST){
                    fieldInputList[4]=rule.score_value__c;
                }else{
                    numberInputList[2]= Decimal.valueOf(rule.score_value__c);  
                }
                             
            
            
          
           
            //INPUT
            String infieldName=String.valueOf(NewList[a].get(fieldInputList[0]));
            String oldinfieldName=String.valueOf(OldList[a].get(fieldInputList[0]));
            String OutFieldScore=String.valueOf(NewList[a].get(fieldInputList[1]));
            
            Decimal lVal=0;
            Decimal eVal=0;
            Decimal oldVal=0;
            Decimal rVal=0;
            String slVal=null;
            String seVal=null;
            String soldVal=null;
            String srVal=null;
            
            if(rule.DataType_Score__c==UtilityConstant.STATIC_STRING || rule.DataType_Score__c==UtilityConstant.PICKLIST){
                
                  SlVal=infieldName;
                  SoldVal=oldinfieldName;
                  SrVal=fieldInputList[3];
                
            }else{
                if(infieldName!=null)
                {
                  lVal=Decimal.valueOf(infieldName);
                }
                
                if(oldinfieldName!=null){
                    oldVal=Decimal.valueOf(oldinfieldName);
                }
                rVal=numberInputList[1];
                
            }
            if(rule.Output_DataType__c==UtilityConstant.STATIC_STRING || rule.Output_DataType__c==UtilityConstant.PICKLIST){
                SeVal=OutFieldScore;
                
            }else{
                if(OutFieldScore!=null){
                    eVal=Decimal.valueOf(OutFieldScore);
                }
            }
            
            
            //OUTPUT
            String scoreField=fieldInputList[1];
            
            
            
            if(oldVal!=lVal || event=='insert' || SlVal!=SoldVal){ // checking the old value and new value 
                       
                 if(numberInputList[0] ==0){
    
                       
                        if(lVal > rVal){
                            
                      if(rule.Output_DataType__c==UtilityConstant.STATIC_STRING|| rule.Output_DataType__c==UtilityConstant.PICKLIST){
                                NewList[a].put(scoreField,fieldInputList[4]);
                      }else {
                            if(fieldInputList[2]==UtilityConstant.STATIC_SET){
                                NewList[a].put(scoreField,numberInputList[2]);
                            }else if(fieldInputList[2]==UtilityConstant.ADD){
                                NewList[a].put(scoreField,(numberInputList[2]+eVal));
                            }else{
                                NewList[a].put(scoreField,(eVal-numberInputList[2]));
                            }
                          }
                        }   
                    }
                 if(numberInputList[0] == 1){
    
                        if(lVal < rVal){
                            
                      if(rule.Output_DataType__c==UtilityConstant.STATIC_STRING || rule.Output_DataType__c==UtilityConstant.PICKLIST){
                                NewList[a].put(scoreField,fieldInputList[4]);
                      }else {
                            if(fieldInputList[2]==UtilityConstant.STATIC_SET){
                                NewList[a].put(scoreField,numberInputList[2]);
                            }else if(fieldInputList[2]==UtilityConstant.ADD){
                                NewList[a].put(scoreField,(numberInputList[2]+eVal));
                            }else{
                                NewList[a].put(scoreField,(eVal-numberInputList[2]));
                            }
                          }
                        }   
                    }
                    if(numberInputList[0] == 2){
    
                   if(rule.DataType_Score__c==UtilityConstant.STATIC_STRING || rule.DataType_Score__c==UtilityConstant.PICKLIST){
                       if(SlVal!=null){ 
                         if(SlVal.equalsignorecase(SrVal)){
                            
                           if(rule.Output_DataType__c==UtilityConstant.STATIC_STRING || rule.Output_DataType__c==UtilityConstant.PICKLIST){
                                NewList[a].put(scoreField,fieldInputList[4]);
                          }else{
                           if(fieldInputList[2]==UtilityConstant.STATIC_SET){
                                NewList[a].put(scoreField,numberInputList[2]);
                            }else if(fieldInputList[2]==UtilityConstant.ADD){
                                NewList[a].put(scoreField,(numberInputList[2]+eVal));
                            }else{
                                NewList[a].put(scoreField,(eVal-numberInputList[2]));
                            }
                        }
                      }
                    }
                   }else{
                    if(lVal == rVal){
                        if(rule.Output_DataType__c==UtilityConstant.STATIC_STRING || rule.Output_DataType__c==UtilityConstant.PICKLIST){
                                NewList[a].put(scoreField,fieldInputList[4]);
                          }else{
                           if(fieldInputList[2]==UtilityConstant.STATIC_SET){
                                NewList[a].put(scoreField,numberInputList[2]);
                            }else if(fieldInputList[2]==UtilityConstant.ADD){
                                NewList[a].put(scoreField,(numberInputList[2]+eVal));
                            }else{
                                NewList[a].put(scoreField,(eVal-numberInputList[2]));
                            }
                        }
                    }
                   }  
                      
                 }
                    if(numberInputList[0] == 3){
    
                        if(lVal >= rVal){
                            
                      if(rule.Output_DataType__c==UtilityConstant.STATIC_STRING || rule.Output_DataType__c==UtilityConstant.PICKLIST){
                                NewList[a].put(scoreField,fieldInputList[4]);
                      }else {
                            if(fieldInputList[2]==UtilityConstant.STATIC_SET){
                                NewList[a].put(scoreField,numberInputList[2]);
                            }else if(fieldInputList[2]==UtilityConstant.ADD){
                                NewList[a].put(scoreField,(numberInputList[2]+eVal));
                            }else{
                                NewList[a].put(scoreField,(eVal-numberInputList[2]));
                            }
                          }
                        }   
                    }
                    if(numberInputList[0] == 4){
    
                        if(lVal <= rVal){
                            
                      if(rule.Output_DataType__c==UtilityConstant.STATIC_STRING|| rule.Output_DataType__c==UtilityConstant.PICKLIST){
                                NewList[a].put(scoreField,fieldInputList[4]);
                      }else {
                            if(fieldInputList[2]==UtilityConstant.STATIC_SET){
                                NewList[a].put(scoreField,numberInputList[2]);
                            }else if(fieldInputList[2]==UtilityConstant.ADD){
                                NewList[a].put(scoreField,(numberInputList[2]+eVal));
                            }else{
                                NewList[a].put(scoreField,(eVal-numberInputList[2]));
                            }
                          }
                        }   
                    }
                    if(numberInputList[0] == 5){
                    
    
                   if(rule.DataType_Score__c==UtilityConstant.STATIC_STRING|| rule.DataType_Score__c==UtilityConstant.PICKLIST){
                       if(SlVal!=null){ 
                         if(!SlVal.equalsignorecase(SrVal)){
                            
                           if(rule.Output_DataType__c==UtilityConstant.STATIC_STRING || rule.Output_DataType__c==UtilityConstant.PICKLIST){
                                NewList[a].put(scoreField,fieldInputList[4]);
                          }else{
                           if(fieldInputList[2]==UtilityConstant.STATIC_SET){
                                NewList[a].put(scoreField,numberInputList[2]);
                            }else if(fieldInputList[2]==UtilityConstant.ADD){
                                NewList[a].put(scoreField,(numberInputList[2]+eVal));
                            }else{
                                NewList[a].put(scoreField,(eVal-numberInputList[2]));
                            }
                        }
                      }
                    }
                   }else{
                    if(lVal != rVal){
                        if(rule.Output_DataType__c==UtilityConstant.STATIC_STRING || rule.Output_DataType__c==UtilityConstant.PICKLIST){
                                NewList[a].put(scoreField,fieldInputList[4]);
                          }else{
                           if(fieldInputList[2]==UtilityConstant.STATIC_SET){
                                NewList[a].put(scoreField,numberInputList[2]);
                            }else if(fieldInputList[2]==UtilityConstant.ADD){
                                NewList[a].put(scoreField,(numberInputList[2]+eVal));
                            }else{
                                NewList[a].put(scoreField,(eVal-numberInputList[2]));
                            }
                        }
                    }
                   }  
                    
                    }
                    
                  if(numberInputList[0] == 6){
                            
                        if(SlVal!=null){
                         if(SlVal.Contains(SrVal)){
                         
                          if(rule.Output_DataType__c==UtilityConstant.STATIC_STRING || rule.Output_DataType__c==UtilityConstant.PICKLIST){
                                NewList[a].put(scoreField,fieldInputList[4]);
                          }else{
                               if(fieldInputList[2]==UtilityConstant.STATIC_SET){
                                NewList[a].put(scoreField,numberInputList[2]);
                            }else if(fieldInputList[2]==UtilityConstant.ADD){
                                NewList[a].put(scoreField,(numberInputList[2]+eVal));
                            }else{
                                NewList[a].put(scoreField,(eVal-numberInputList[2]));
                            }
                          }
                         }
                        } 
                    }
                  if(numberInputList[0] == 7){
                            
                        if(SlVal!=null){
                         if(!SlVal.Contains(SrVal)){
                         if(rule.Output_DataType__c==UtilityConstant.STATIC_STRING || rule.Output_DataType__c==UtilityConstant.PICKLIST){
                                NewList[a].put(scoreField,fieldInputList[4]);
                           }else{
                               if(fieldInputList[2]==UtilityConstant.STATIC_SET){
                                NewList[a].put(scoreField,numberInputList[2]);
                            }else if(fieldInputList[2]==UtilityConstant.ADD){
                                NewList[a].put(scoreField,(numberInputList[2]+eVal));
                            }else{
                                NewList[a].put(scoreField,(eVal-numberInputList[2]));
                            }
                          }
                         }
                        }
                    }
            }
        }
     }    
    return NewList;                 
    }   
    catch(Exception e){
ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
return null;
}
}
 
}