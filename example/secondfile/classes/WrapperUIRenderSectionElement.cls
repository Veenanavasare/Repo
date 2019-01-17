public class WrapperUIRenderSectionElement extends WrapperUIGridElemnt{
 List<WrapperUIGridElemnt>    sectionDataElementListRW;
     public WrapperUIElementHeader header {get;set;}
    public void setHeader(String name){
   
        header.setName(name);
        header.setvalue(name);
        header.setLabel(name);
        this.setChildElements('WrapperUIElementHeader',header);
    }
    
    public WrapperUIElementHeader getHeader(String name){
     WrapperUIElementHeader   header2= (WrapperUIElementHeader ) this.getChildElements('WrapperUIElementHeader').firstSIVARElement();
  
        return header2;
    }
    public WrapperUIRenderSectionElement (){
    
    super();
    this.setType('WrapperUIRenderSectionElement');
    header = new WrapperUIElementHeader (); 
        
  sectionDataElementListRW= new List<WrapperUIGridElemnt> ();
         this.gversion=0;
             this.sversion=0;
    }
   
   // public List<WrapperUIGridElemnt>  sectionDataElementList{get;set;}
    
    public string elementStyleDetails{get;set;}
    public void addWrapperUIElements(String name,String value,integer rowID,integer colID){
        
      //  system.debug('addling GE:name'+name);
        WUIRenderComponentBuilderHelper  wuiBhelper= new WUIRenderComponentBuilderHelper ();
        SIVARElementList   sectionGridElementLists2=wuiBhelper.filterWUIEleOnPosition(rowID,colID,this.getChildElements('WrapperUIGridElemnt'));
        SIVARElementList   sectionGridElementLists=wuiBhelper.filterWUIEleOnName(name,sectionGridElementLists2);
        WrapperUIGridElemnt  wge1= (WrapperUIGridElemnt  ) sectionGridElementLists.getSIVARElements().firstSIVARElement();
        if(wge1!=null){
            wge1.setValue(value);
            wge1.setRowID(rowID);
            wge1.setColID(colID);
            wge1.incrementsVersion();
        }else {
            WrapperUIGridElemnt  wge= new  WrapperUIGridElemnt  ();
            wge.setName(name);
            wge.setValue(value);
            wge.setLabel(name);
            wge.setRowID(rowID);
            wge.setColID(colID);
            wge.incrementsVersion();
            //    sectionDataElementList.add(wge);
        this.setChildElements('WrapperUIGridElemnt',wge);

        
        }
       // system.debug('sectionDataElementList at end of addWrapperUIElements:'+this);
    }
    
    public List<WrapperUIGridElemnt> getSectionDataElementList (){

//List<WrapperUIGridElemnt> wuirSEList  =(List<WrapperUIGridElemnt>) this.getChildElements('WrapperUIGridElemnt').getSIVARElementList();

List<WrapperUIGridElemnt> wuirSEList  = new List<WrapperUIGridElemnt>();
SIVARElementList wuirSE_s_List =  this.getChildElements('WrapperUIGridElemnt');
SIVARElementIterator sei= wuirSE_s_List.iterator();
while(sei.hasNext()){
WrapperUIGridElemnt wuiSec=(WrapperUIGridElemnt)sei.next();
  //  wuiSec.incrementVersion();
wuirSEList.add(wuiSec);
}
return wuirSEList  ;

//return wuirSEList ;
}
    
    
public List<WrapperUIGridElemnt> getSectionDataElementListRW (){

//List<WrapperUIGridElemnt> wuirSEList  =(List<WrapperUIGridElemnt>) this.getChildElements('WrapperUIGridElemnt').getSIVARElementList();

//List<WrapperUIGridElemnt> wuirSEList  = new List<WrapperUIGridElemnt>();
/**
SIVARElementList wuirSE_s_List =  this.getChildElements('WrapperUIGridElemnt');
SIVARElementIterator sei= wuirSE_s_List.iterator();
while(sei.hasNext()){
WrapperUIGridElemnt wuiSec=(WrapperUIGridElemnt)sei.next();
    wuiSec.incrementversion();
sectionDataElementListRW.add(wuiSec);
}**/
return sectionDataElementListRW  ;

//return wuirSEList ;
}       
        
        
        
        
    public override virtual String toString()
    {
        String[] returnValue =new String [0];
        
        
        returnValue.add('<WrapperUIRenderSectionElement>');
          returnValue.add('<getversion>' + this.gversion);
        returnValue.add('</getversion>');
          returnValue.add('<setversion>' + this.sversion);
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
         returnValue.add('<stylingConfigurationList>' + this.getStylingConfigurationList());
        returnValue.add('</stylingConfigurationList>'); 
        returnValue.add('<sectionDataElementList>' + getSectionDataElementList());
        returnValue.add('</sectionDataElementList>');
        /** returnValue.add('<sectionDataElementListRW>' + logRWlist());
        returnValue.add('</sectionDataElementListRW>');**/
        returnValue.add('</WrapperUIRenderSectionElement>');
        String returnValueStr= String.join(returnValue, ' ');
        return returnValueStr;
    }
    
           public void prepRWReturnList(){
            SIVARElementList wuirSE_s_List =  this.getChildElements('WrapperUIGridElemnt');
            SIVARElementIterator sei= wuirSE_s_List.iterator();
            while(sei.hasNext()){
            WrapperUIGridElemnt wuiSec=(WrapperUIGridElemnt)sei.next();
            //    wuiSec.incrementversion();
            sectionDataElementListRW.add(wuiSec);
            }
                        }
    
    public SIVARElementList logRWlist(){
        SIVARElementList sList= new SIVARElementList();
        sList.add(sectionDataElementListRW);
        return sList;
    }
    
}