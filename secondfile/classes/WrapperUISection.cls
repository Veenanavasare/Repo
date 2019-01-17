public class WrapperUISection extends WrapperUIGridElemnt{
public List<WrapperUIRenderSectionElement> wuirSEListRW ;//{get;set;} 
  public WrapperUIElementHeader header {get;set;}
public WrapperUISection (){
//wuirSEList = new List<WrapperUIRenderSectionElement>();
 super();
 this.setType('WrapperUISection');
 header = new WrapperUIElementHeader ();
 wuirSEListRW = new List<WrapperUIRenderSectionElement>();
 this.sversion=0;
 
 this.gversion=0;
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

public List<WrapperUIRenderSectionElement> getWrapperUIRenderSectionElement (){

//List<WrapperUIRenderSectionElement> wuirSEList   =(List<WrapperUIRenderSectionElement>) this.getChildElements('WrapperUIRenderSectionElement').getSIVARElementList();
List<WrapperUIRenderSectionElement> wuirSEList   =new List<WrapperUIRenderSectionElement>();

SIVARElementList wuirSE_s_List =  this.getChildElements('WrapperUIRenderSectionElement');
SIVARElementIterator sei= wuirSE_s_List.iterator();
while(sei.hasNext()){
WrapperUIRenderSectionElement wuiSec=(WrapperUIRenderSectionElement)sei.next();
wuirSEList.add(wuiSec);
}
return wuirSEList  ;

//return wuirSEList ;
}
 
 
 
 
public SivarElementMap getWrapperUIRenderSectionElementMap (){

//List<WrapperUIRenderSectionElement> wuirSEList   =(List<WrapperUIRenderSectionElement>) this.getChildElements('WrapperUIRenderSectionElement').getSIVARElementList();
/**List<WrapperUIRenderSectionElement> wuirSEList   =new List<WrapperUIRenderSectionElement>();

SIVARElementList wuirSE_s_List =  
SIVARElementIterator sei= wuirSE_s_List.iterator();
while(sei.hasNext()){
WrapperUIRenderSectionElement wuiSec=(WrapperUIRenderSectionElement)sei.next();
wuirSEList.add(wuiSec);
}**/
return this.getChildElementsMap('WrapperUIRenderSectionElement');

//return wuirSEList ;
}


   
public List<WrapperUIRenderSectionElement> getWrapperUIRenderSectionElementRW (){

//List<WrapperUIRenderSectionElement> wuirSEList   =(List<WrapperUIRenderSectionElement>) this.getChildElements('WrapperUIRenderSectionElement').getSIVARElementList();
//List<WrapperUIRenderSectionElement> wuirSEList   =new List<WrapperUIRenderSectionElement>();
/**
SIVARElementList wuirSE_s_List =  this.getChildElements('WrapperUIRenderSectionElement');
SIVARElementIterator sei= wuirSE_s_List.iterator();
while(sei.hasNext()){
WrapperUIRenderSectionElement wuiSec=(WrapperUIRenderSectionElement)sei.next();
wuirSEListRW.add(wuiSec);
}**/
return wuirSEListRW  ;


}    
    

public void addWrapperUIRenderSectionElement ( WrapperUIRenderSectionElement sectionElement){
    sectionElement.incrementsVersion();
this.setChildElements('WrapperUIRenderSectionElement',sectionElement);
}

public void addWrapperUIRenderSectionElementMap (String key, WrapperUIRenderSectionElement sectionElement){
    sectionElement.incrementsVersion();
this.setChildElementsMap('WrapperUIRenderSectionElement',key,sectionElement);
}

public override virtual String toString()
    {
        String[] returnValue =new String [0];
        
        
        returnValue.add('<WrapperUISection >');
        returnValue.add('<getversion>' + gversion);
        returnValue.add('</getversion>');     
        returnValue.add('<setversion>' + sversion);
        returnValue.add('</setversion>'); 
           returnValue.add('<name>' + name);
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
        returnValue.add('<WrapperUIRenderSectionElementList>' + getWrapperUIRenderSectionElement());
        returnValue.add('</WrapperUIRenderSectionElementList>');
        returnValue.add('<WrapperUIRenderSectionElementMap>' + getWrapperUIRenderSectionElementMap());
        returnValue.add('</WrapperUIRenderSectionElementMap>');
        
      /**   returnValue.add('<WrapperUIRenderSectionElementListRW>' + logRWlist());
        returnValue.add('</WrapperUIRenderSectionElementListRW>');**/
            returnValue.add('<stylingConfigurationList>' + this.getStylingConfigurationList());
        returnValue.add('</stylingConfigurationList>');
         returnValue.add('</WrapperUISection >');
        String returnValueStr= String.join(returnValue, ' ');
        return returnValueStr;
    }
    
        public void prepRWReturnList(){
                   
            SIVARElementList wuirSE_s_List =  this.getChildElements('WrapperUIRenderSectionElement');
            SIVARElementIterator sei= wuirSE_s_List.iterator();
            while(sei.hasNext()){
            WrapperUIRenderSectionElement wuiSec=(WrapperUIRenderSectionElement)sei.next();
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