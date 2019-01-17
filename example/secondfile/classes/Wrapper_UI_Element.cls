public abstract class Wrapper_UI_Element implements SIVARElement {
        public String name{get;set;}
        public String label{get;set;}
        public String type{get;set;}
        public boolean dirtyFlag{get;set;}
        public Type tObject{get;set;}
        public String objectType{get;set;}
        
    public integer gversion{get;set;} 

    public integer sversion{get;set;} 
      public String value;//{get;set;}
      /**public   WGEValue  elementValue;
        
         public class WGEValue {
        public string fieldvalue { get; set; }
        public WGEValue (String fv) {
            this.fieldvalue = fv;
        }
         public override virtual    String toString()
        {
            String[] returnValue =new String [0];
            
            
            returnValue.add('<WGEValue>');
            returnValue.add('<fieldvalue>' + fieldvalue);
            returnValue.add('</fieldvalue>'); 
             returnValue.add('</WGEValue>');
            String returnValueStr= String.join(returnValue, ' ');
            return returnValueStr;
        }
        }
        
        **/
        public string uiELementStyleDetails{get;set;}
        public string uiValueStyleDetails{get;set;}
        public string uiLableStyleDetails{get;set;}
        
        
        
         public void setdirtyFlag(boolean flag){
            dirtyFlag=flag;
        }
        
        
        public boolean getdirtyFlag(){
            return dirtyFlag;
        }
         
        public void   setsVersion(integer v){
            sversion=v;
        }
        
        public void incrementsVersion(){
            sversion=sversion+1;
        }
        public integer getsVersion(){
            return sversion;
        }
        
        public void   setgVersion(integer v){
            gversion=v;
        }
        
        public void incrementgVersion(){
            gversion=gversion+1;
        }
        public integer getgVersion(){
            return gversion;
        }
         public void setTObject(Type objType){
            tObject=objType;
        }
        
        
        public Type getTObject(){
            return tObject;
        }
        
        
        
        
         public void setObjectType(String objType){
            objectType=objType;
        }
        
        
        public String getObjectType(){
            return objectType;
        }
        
        
        
        
        
        
        
        public string getName(){
            return name;
        }
        
        
        public string getLabel(){
            return label;
        }
        public string getType(){
            return type;
        }
        public  void setName(String namep){
            name=namep;
        }
        
        public String getValue(){
            return value;
        }
        public void setvalue(String valuep){
        value=valuep;
        
      
        }
        
        public  void setLabel(String labelp){
            label=labelp;
        }
        
        
        public  void setType(String typep){
            type=typep;
        }
        
        public override virtual    String toString()
        {
            String[] returnValue =new String [0];
            
            
            returnValue.add('<Wrapper_UI_Element >');
            returnValue.add('<getversion>' + gversion);
            returnValue.add('</getversion>'); 
             returnValue.add('<setversion>' + sversion);
            returnValue.add('</setversion>');
            returnValue.add('<name>' + name);
            returnValue.add('</name>');  returnValue.add('<label>' + label);
            returnValue.add('</label>');  returnValue.add('<type>' + type);
            returnValue.add('</type>');    returnValue.add('</Wrapper_UI_Element >');
            String returnValueStr= String.join(returnValue, ' ');
            return returnValueStr;
        }
        
    }