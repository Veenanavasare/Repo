public class WrapperUIRenderComponent extends WrapperUIGridElemnt{ 

public List<WrapperUISection> wuirSEListRW ;//{get;set;} //
public static map<string,string> flowidentifierMap=new map<string,string>();
String flow_idx;
boolean childHeaders=true;

public void setChildHeaders(boolean b){
childHeaders=b;
}
public boolean ChildHeadersNeeded(){
return childHeaders;
}
public void setFlowID(String flowID){
system.debug('setting flowID to flowID'+flowID);
this.flow_idx=flowID;

system.debug('flowId is set to '+this.flow_idx);
}

public String getFlowID(){

system.debug('returning flowId is '+this.flow_idx);
return this.flow_idx;
}
public WrapperUIElementHeader header {get;set;}
public WrapperUIRenderComponent (String name){
super();
this.setName(name);
this.setType('WrapperUIRenderComponent');
wuirSEListRW = new List<WrapperUISection>();
header = new WrapperUIElementHeader ();
}

 public void setHeader(String name){
   
        header.setName(name);
        header.setValue(name);
        header.setLabel(name);
        this.setChildElements('WrapperUIElementHeader',header);
    }
    
    public WrapperUIElementHeader getHeader(String name){
  WrapperUIElementHeader   header2= (WrapperUIElementHeader ) this.getChildElements('WrapperUIElementHeader').firstSIVARElement();
        return header2;
    }

public List<WrapperUISection> getWrapperUISections(){
//List<WrapperUISection> wuirSEList  =this.getChildElements('WrapperUISection').getSIVARElements();
List<WrapperUISection> wuirSEList  = new List<WrapperUISection>();
SIVARElementList wuirSE_s_List =  this.getChildElements('WrapperUISection');
//system.debug('WrapperUISection on getChildElements:'+wuirSE_s_List .size());
SIVARElementIterator sei= wuirSE_s_List.iterator();
while(sei.hasNext()){
WrapperUISection wuiSec=(WrapperUISection)sei.next();
//    wuisec.incrementversion();
wuirSEList.add(wuiSec);
}
return wuirSEList  ;
} 




public SIVARElementMap  getWrapperUISectionMap(){
//List<WrapperUISection> wuirSEList  =this.getChildElements('WrapperUISection').getSIVARElements();
//Map<String,WrapperUISection>  wuirSecMap  =new Map<String,WrapperUISection>();
SIVARElementMap wuirSEcMap =  this.getChildElementsMap('WrapperUISection');
//system.debug('WrapperUISection on getChildElements:'+wuirSE_s_List .size());
/**SIVARElementIterator sei= wuirSE_s_List.keySet();
while(sei.hasNext()){
WrapperUISection wuiSec=(WrapperUISection)sei.next();
//    wuisec.incrementversion();
wuirSEList.add(wuiSec);
}**/
return wuirSEcMap  ;
} 


public List<WrapperUISection> getWrapperUISectionsRW(){
//List<WrapperUISection> wuirSEList  = new List<WrapperUISection>();
/**SIVARElementList wuirSE_s_List =  this.getChildElements('WrapperUISection');
SIVARElementIterator sei= wuirSE_s_List.iterator();
while(sei.hasNext()){
WrapperUISection wuiSec=(WrapperUISection)sei.next();
wuirSEListRW.add(wuiSec);
} **/
return wuirSEListRW ;
} 

public void addWrapperUISections(WrapperUISection wus){
  //  wus.incrementsVersion();
this.setChildElements('WrapperUISection',wus);
} 

public void addWrapperUISectionsMap(String key,WrapperUISection wus){
 //   wus.incrementsVersion();
this.setChildElementsMap('WrapperUISection',key,wus);
} 
 




public override virtual String toString()
    {
        String[] returnValue =new String [0];
        
        
        returnValue.add('<WrapperUIRenderComponent>');
        returnValue.add('<name>' + name);
        returnValue.add('<getversion>' + gversion);
        returnValue.add('</getversion>');
        returnValue.add('<setversion>' + sversion);
        returnValue.add('</setversion>');
        returnValue.add('</name>');  returnValue.add('<label>' + label);
        returnValue.add('</label>');  returnValue.add('<type>' + type);
        returnValue.add('</type>');  
returnValue.add('<header>' + header);
        returnValue.add('</header>');
        returnValue.add('<style>' + this.getStyle());
        returnValue.add('</style>');
        returnValue.add('<colID>' + this.getColID());
        returnValue.add('</colID>');  
        returnValue.add('<rowID>' + this.getRowID());
        returnValue.add('</rowID>');  
        returnValue.add('<WrapperUISectionList>' + getWrapperUISections());
        returnValue.add('</WrapperUISectionList>');
        
        returnValue.add('<WrapperUISectionMap>'+getWrapperUISectionMap());
        returnValue.add('</WrapperUISectionMap>');
      /**   returnValue.add('<WrapperUISectionListRW>' + this.logRWlist());
        returnValue.add('</WrapperUISectionListRW>');**/
        returnValue.add('<stylingConfigurationList>' + this.getStylingConfigurationList());
        returnValue.add('</stylingConfigurationList>');
         returnValue.add('</WrapperUIRenderComponent>');
        String returnValueStr= String.join(returnValue, ' ');
        return returnValueStr;
    }
    public void prepRWReturnList(){
                SIVARElementList wuirSE_s_List =  this.getChildElements('WrapperUISection');
        SIVARElementIterator sei= wuirSE_s_List.iterator();
        while(sei.hasNext()){
        WrapperUISection wuiSec=(WrapperUISection)sei.next();
        wuiSec.prepRWReturnList();
        wuirSEListRW.add(wuiSec);
        }
    }
    
 
    
               public SIVARElementList logRWlist(){
        SIVARElementList sList= new SIVARElementList();
        sList.add(wuirSEListRW);
        return sList;
    }
}