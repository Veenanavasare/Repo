/* 
 Name:  WrapperUIRenderComponentBuilder
 Type: Class 
 
 Description: 
 */ 
public class WrapperUIRenderComponentBuilder {
private WrapperUIRenderComponent wrc= null;
public static map<string,string> flowidentifierMap=new map<string,string>();

public static map<String,List<String>>  hirearchyMap= new  map<String,List<String>>();
static
{
    flowidentifierMap.put('Change'+'MACD'+'Feature'+'UBB_ADD','1');
    flowidentifierMap.put('Change'+'MACD'+'Feature'+'UBB_CHANGE','2');
    flowidentifierMap.put('Change'+'MACD'+'Feature'+'UBB_REMOVE','3');
    flowidentifierMap.put('Change'+'MACD'+'Feature'+'PORT_SPEED_CHANGE','4');
    flowidentifierMap.put('Change'+'MACD'+'Feature'+'COS_REMOVE','5');
    flowidentifierMap.put('ViewTable'+'BuyFlow'+'Flow'+'Review','6');
     flowidentifierMap.put('RegenerateRDSExcel'+'BuyFlow'+'Flow'+'ExportRds','7');
    List<String> wrapperRCHearchyList=new List<String>();
    wrapperRCHearchyList.add(BuyFlowConstant.WRAPPERUISECTION);
     wrapperRCHearchyList.add(BuyFlowConstant.WRAPPERUIELEMENTHEADER);
       hirearchyMap.put('WrapperUIRenderComponent',wrapperRCHearchyList);
    
    List<String> wrapperSectionHearchyList=new List<String>();
    wrapperSectionHearchyList.add(BuyFlowConstant.WRAPPERUIRENDERSECTIONELEMENT);
     wrapperSectionHearchyList.add(BuyFlowConstant.WRAPPERUIELEMENTHEADER);
       hirearchyMap.put('WrapperUISection',wrapperSectionHearchyList);
       
        List<String> wrapperSectionEleHearchyList=new List<String>();
    wrapperSectionEleHearchyList.add(BuyFlowConstant.WRAPPERUIGRIDELEMNT);
     wrapperSectionEleHearchyList.add(BuyFlowConstant.WRAPPERUIELEMENTHEADER);
       hirearchyMap.put('WrapperUIRenderSectionElement',wrapperSectionEleHearchyList);
}
String flowId=SpecialCharacterBuyFlowConstant.CONCAT;



/* 
 Name: WrapperUIRenderComponentBuilder
 Description: 
 */ 
public WrapperUIRenderComponentBuilder (WrapperUIRenderComponent wrc_p){
wrc= wrc_p;
}


/* 
 Name: WrapperUIRenderComponentBuilder
 Description: 
 */ 
public WrapperUIRenderComponentBuilder (WrapperUIRenderComponent wrc_p,String OperationType,String Flow,String FunctionType,String FunctionID){



wrc= wrc_p;

wrc.setHeader(wrc.getName());
flowId=flowidentifierMap.get(OperationType+Flow+FunctionType+FunctionID);

wrc.setFlowID(flowId);

}
/* 
 Name: buildSection
 Description: 
 */ 
public WrapperUISection  buildSection(String sectionHeader, integer rowID , integer colId){
    try{
 WUIRenderComponentBuilderHelper  wuiBhelper= new WUIRenderComponentBuilderHelper ();
 SIVARElementList   sectionslist=wuiBhelper.filterWUIEleOnPosition(rowID ,colId,wrc.getChildElements('WrapperUISection')); 
 WrapperUISection  wuisection=null;
    if(sectionslist.size()<=0){
   wuisection= new WrapperUISection  ();
    wuisection.setName(sectionHeader);
      if(wrc.ChildHeadersNeeded()){
     wuisection.setHeader(sectionHeader);
      }
    wuisection.setRowID(rowID );
    //By design sections are first colum identified bt BuyFlowConstant.SIVARConst_0
    wuisection.setColID(0);
    }else {
    //do nothing 
    }
    return wuisection;
    }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                return null;
            }
 }

 
 
/* 
 Name: buildSection
 Description: 
 */ 
 public WrapperUISection  buildSection(String sectionHeader, integer rid , integer cid,boolean sectionAsColumn){
     try{
 WUIRenderComponentBuilderHelper  wuiBhelper= new WUIRenderComponentBuilderHelper ();
 integer rowID=rid;
 integer colId=cid;
 
 if(sectionAsColumn){
     rowID=0;
 }else{
     colId=0;
 }
 SIVARElementList   sectionslist=wuiBhelper.filterWUIEleOnPosition(rowID ,colId,wrc.getChildElements('WrapperUISection')); 
 
 
 WrapperUISection  wuisection=null;
    if(sectionslist.size()<=0){
   wuisection= new WrapperUISection  ();
    wuisection.setName(sectionHeader);
      if(wrc.ChildHeadersNeeded()){
     wuisection.setHeader(sectionHeader);
      }
    wuisection.setRowID(rowID );
    //By design sections are first colum identified bt BuyFlowConstant.SIVARConst_0
    wuisection.setColID(colId);
    }else {
    //do nothing 
    }
    return wuisection;
    }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                return null;
            }
 }

/*loadSectionElement*/
public void loadSectionElement(String name,String value,String sectionElementheader,String sectionHeader,
                                integer rowID, integer colID) {
                                    try{
                                WUIRenderComponentBuilderHelper  wuiBhelper= new WUIRenderComponentBuilderHelper ();
   //By design sections are first colum identified bt BuyFlowConstant.SIVARConst_0
   
    SIVARElementList   sectionslist=wuiBhelper.filterWUIEleOnPosition(rowID ,0,wrc.getChildElements('WrapperUISection'));
   WrapperUISection wus= (WrapperUISection ) sectionslist.getSIVARElements().firstSIVARElement();

   if(wus!=null){
       buildSectionElement(name,value,sectionElementheader,rowID,colID,wus);
       }else{
     
    WrapperUISection  wuisection=  buildSection(sectionHeader, rowID , 0);
       buildSectionElement(name,value,sectionElementheader,rowID,colID,wuisection);
        wrc.addWrapperUISections(wuisection);
       }
       
}catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
               
            }
 }
 /*buildSectionElement*/
  private void buildSectionElement(String name,String value,String sectionElementheader,integer rowID,integer colID,WrapperUISection  wus){
    
    try{
    
     WUIRenderComponentBuilderHelper  wuiBhelper= new WUIRenderComponentBuilderHelper ();
      SIVARElementList   sectionElementsList= wuiBhelper.filterWUIEleOnPosition(rowID,colID,wus.getChildElements('WrapperUIRenderSectionElement'));
        WrapperUIRenderSectionElement wuse= (WrapperUIRenderSectionElement ) sectionElementsList.getSIVARElements().firstSIVARElement();
      if(wuse!=null){
    
       wuse.addWrapperUIElements(name,value,rowID,colID);
       }else {
       wuse= new WrapperUIRenderSectionElement ();
         if(wrc.ChildHeadersNeeded()){
       wuse.setHeader(sectionElementheader);
       }
       wuse.setName(sectionElementheader);
       wuse.setRowID(rowID);
        wuse.setColID(colID);
         wuse.addWrapperUIElements(name,value,rowID,colID);
       wus.addWrapperUIRenderSectionElement(wuse);
       } 
       }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                
            }
       }
 
 

/* 
 Name: getWrapperUIRenderComponent
 Description: 
 */ 
public WrapperUIRenderComponent getWrapperUIRenderComponent(){
 return wrc;
 }

/* 
 Name: setStyles
 Description: 
 */ 
public void setStyles(){
        try{
    StylingConfigurationIdentifierRule wrcSyleRule=new StylingConfigurationIdentifierRule ();
    WrapperBE wbe= new WrapperBE();
    wbe.setwrapperUIRenderComponent(wrc);
    wrcSyleRule.execute(wbe);
     StyleOverrideRUle   srcrule= new StyleOverrideRUle ();
   SIVARElementList applicableConfigList=(SIVARElementList)  srcrule.execute(wrc.getStylingConfigurationList());
   wrc.setStylingConfigurationList(applicableConfigList);
    StyleWrapperUIElementRule srcr=new StyleWrapperUIElementRule();
    srcr.execute(wrc);
     StyleWrapperUIElementRule srcr2=new StyleWrapperUIElementRule(hirearchyMap.get(wrc.getType()));
    srcr2.execute(wrc);
    setChildElementsStyles(wrc,'WrapperUISection');
     // setChildElementsStyles(wrc);
//   setChildElementsStylesAll(wrc);
   setChildElementsStylesAllByNameOnSelf(wrc,0);
   }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
              
            }
}

/* 
 Name: setChildElementsStylesAllByNameOnSelf
 Description: 
 */ 
 public void setChildElementsStylesAllByNameOnSelf(WrapperUIGridElemnt wrc,integer depth){
     try{
 
   SIVARElementList styleConfigurationList=wrc.getStylingConfigurationList();
  List<String> hirearchyList= hirearchyMap.get(wrc.getType());
  SIVARConfigurationBasedFilter  overridingStyleConfigsFilter= new SIVARConfigurationBasedFilter (styleConfigurationList,SIVARConfigIdentifierDataKey.OVERRIDING_ENABLE,'true');
  
 SIVARConfigurationBasedFilter configsOnCoreFilter=  new SIVARConfigurationBasedFilter (overridingStyleConfigsFilter,SIVARConfigIdentifierDataKeyHelper.valueOf(wrc.getType()+'_Name'),wrc.getName());
 integer tosend=depth+1;
  if(hirearchyList!=null){
 Iterator<String> hirearchyItr=hirearchyList.iterator();
  while(hirearchyItr.hasNext()){
           String childElementType=hirearchyItr.next();
             SIVARElementList wrapperUISectionList= wrc.getChildElements(childElementType);
             SIVARElementIterator sItr= wrapperUISectionList.iterator();
              while(sItr.hasNext()){
            WrapperUIGridElemnt wuiSection=(WrapperUIGridElemnt) sItr.next();
         SIVARConfigurationBasedFilter  configsOnCore2ndFilter=  new SIVARConfigurationBasedFilter (configsOnCoreFilter,SIVARConfigIdentifierDataKeyHelper.valueOf(wuiSection.getType()+'_Name'),wuiSection.getName());
             SIVARElementList  styleConfigurations=    configsOnCore2ndFilter.getSIVARElements();
            wuiSection.setStylingConfigurationList(styleConfigurations);
           StyleWrapperUIElementRule swuisr= new StyleWrapperUIElementRule ();
            swuisr.execute(wuiSection);
                StyleWrapperUIElementRule srcr2=new StyleWrapperUIElementRule(hirearchyMap.get(wuiSection.getType()));
            srcr2.execute(wuiSection);
            setChildElementsStylesAllByNameOnSelf(wuiSection,tosend);
  
         }
              }
  }
  }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                
            }
 }
/* 
 Name: setChildElementsStylesAll
 Description: 
 */ 
 public void setChildElementsStylesAll(WrapperUIGridElemnt wrc){
 try{
   SIVARElementList styleConfigurationList=wrc.getStylingConfigurationList();
   
  List<String> hirearchyList= hirearchyMap.get(wrc.getType());
  if(hirearchyList!=null){
 Iterator<String> hirearchyItr=hirearchyList.iterator();
  while(hirearchyItr.hasNext()){
           String childElementType=hirearchyItr.next();
             SIVARElementList wrapperUISectionList= wrc.getChildElements(childElementType);
             SIVARElementIterator sItr= wrapperUISectionList.iterator();
              while(sItr.hasNext()){
            WrapperUIGridElemnt wuiSection=(WrapperUIGridElemnt) sItr.next();
           
            wuiSection.setStylingConfigurationList(styleConfigurationList);
           StyleWrapperUIElementRule swuisr= new StyleWrapperUIElementRule ();
            swuisr.execute(wuiSection);
                StyleWrapperUIElementRule srcr2=new StyleWrapperUIElementRule(hirearchyMap.get(wuiSection.getType()));
            srcr2.execute(wuiSection);
            setChildElementsStylesAll(wuiSection);
  
         }
              }
  }
  }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                
            }
 }

/*
/* 
 Name: setChildElementsStyles
 Description: 
 
  public void setChildElementsStyles(WrapperUIGridElemnt wrc){
 try{
   SIVARElementList styleConfigurationList=wrc.getStylingConfigurationList();
     SIVARElementList wrapperUISectionList= wrc.getChildElements(hirearchyMap.get(wrc.getType()));
     SIVARElementIterator sItr= wrapperUISectionList.iterator();
      while(sItr.hasNext()){
    WrapperUIGridElemnt wuiSection=(WrapperUIGridElemnt) sItr.next();
   
    wuiSection.setStylingConfigurationList(styleConfigurationList);
   StyleWrapperUIElementRule swuisr= new StyleWrapperUIElementRule ();
    swuisr.execute(wuiSection);
        StyleWrapperUIElementRule srcr2=new StyleWrapperUIElementRule(hirearchyMap.get(wuiSection.getType()));
    srcr2.execute(wuiSection);
    setChildElementsStyles(wuiSection);
  
    }
    }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                
            }
 }

*/ 
/* 
 Name: setChildElementsInheritStyles
 Description: 
 */ 
public void setChildElementsInheritStyles( WrapperUIGridElemnt wrc ,String childName,String secondGenChild){
    try{
    SIVARElementList styleConfigurationList=wrc.getStylingConfigurationList();
    
     SIVARElementList wrapperUISectionList= wrc.getChildElements(childName);
   
    SIVARElementIterator sItr= wrapperUISectionList.iterator();
    
    while(sItr.hasNext()){
    WrapperUIGridElemnt wuiSection=(WrapperUIGridElemnt) sItr.next();
    wuiSection.setStylingConfigurationList(styleConfigurationList);
  // StyleWrapperUIElementRule swuisr= new StyleWrapperUIElementRule (secondGenChild);
    //swuisr.execute(wuiSection);
    
  
    }
    }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                
            }
}





/* 
 Name: setChildElementsStyles
 Description: 
 */ 
public void setChildElementsStyles( WrapperUIGridElemnt wrc ,String childName){
    try{
    SIVARElementList styleConfigurationList=wrc.getStylingConfigurationList();
    
     SIVARElementList wrapperUISectionList= wrc.getChildElements(childName);
   
    SIVARElementIterator sItr= wrapperUISectionList.iterator();
    
    while(sItr.hasNext()){
    WrapperUIGridElemnt wuiSection=(WrapperUIGridElemnt) sItr.next();
    wuiSection.setStylingConfigurationList(styleConfigurationList);
   StyleWrapperUIElementRule swuisr= new StyleWrapperUIElementRule ();
    swuisr.execute(wuiSection);
  
    }
    }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                
            }
}

/* 
 Name: setWUISectionStyles
 Description: 
 */ 
public void setWUISectionStyles( WrapperUIRenderComponent wrc ){
    try{
List<Wrapper_UI_Element> wuieles= wrc.getWrapperUISections();
    SIVARElementList styleConfigurationList=wrc.getStylingConfigurationList();
    
     SIVARElementList wrapperUISectionList= new SIVARElementList() ;
    wrapperUISectionList.add(wuieles);
    SIVARElementIterator sItr= wrapperUISectionList.iterator();
    
    while(sItr.hasNext()){
    WrapperUISection wuiSection=(WrapperUISection) sItr.next();
    wuiSection.setStylingConfigurationList(styleConfigurationList);
   StyleWrapperUIElementRule swuisr= new StyleWrapperUIElementRule ();
    swuisr.execute(wuiSection);
  
    }
    }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                
            }
}

/* 
 Name: executePostBuildPrep
 Description: 
 */ 
  public void executePostBuildPrep(WrapperUIRenderComponent wrc){
      try{
     wrc.prepRWReturnList();
     }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                
            }
  }
  /*loadSectionElementAsCoreMap*/
    public void loadSectionElementAsCoreMap(String name,String value,String sectionElementheader,String sectionHeader,
                                integer rowID, integer colID,boolean sectionAsColumn) {
                                    try{
                                WUIRenderComponentBuilderHelper  wuiBhelper= new WUIRenderComponentBuilderHelper ();
   //By design sections are first colum identified bt BuyFlowConstant.SIVARConst_0
   
    WrapperUISection   wus=(WrapperUISection )wuiBhelper.filterWUIEleMapOnKey(rowID ,0,wrc.getChildElementsMap('WrapperUISection'));
 //  WrapperUISection wus= (WrapperUISection ) sectionslist.getSIVARElements().firstSIVARElement();

   if(wus!=null){
       buildSectionElementAsCoreMap(name,value,sectionElementheader,rowID,colID,wus);
       }else{
     
    WrapperUISection  wuisection=  buildSection(sectionHeader, rowID , colID,sectionAsColumn);
       buildSectionElementAsCoreMap(name,value,sectionElementheader,rowID,colID,wuisection);
        wrc.addWrapperUISectionsMap(rowID+SpecialCharacterBuyFlowConstant.UNDERSCORE+BuyFlowConstant.SIVARConst_0,wuisection);
       }
       
}catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
               
            }
 }
    
/*loadSectionElementAsCore*/
  public void loadSectionElementAsCore(String name,String value,String sectionElementheader,String sectionHeader,
                                integer rowID, integer colID,boolean sectionAsColumn) {
                                    try{
                                WUIRenderComponentBuilderHelper  wuiBhelper= new WUIRenderComponentBuilderHelper ();
   //By design sections are first colum identified bt BuyFlowConstant.SIVARConst_0
   
    SIVARElementList   sectionslist=wuiBhelper.filterWUIEleOnPosition(rowID ,0,wrc.getChildElements('WrapperUISection'));
   WrapperUISection wus= (WrapperUISection ) sectionslist.getSIVARElements().firstSIVARElement();

   if(wus!=null){
       buildSectionElementAsCore(name,value,sectionElementheader,rowID,colID,wus);
       }else{
     
    WrapperUISection  wuisection=  buildSection(sectionHeader, rowID , colID,sectionAsColumn);
       buildSectionElementAsCore(name,value,sectionElementheader,rowID,colID,wuisection);
        wrc.addWrapperUISections(wuisection);
       }
       }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
               
            }

 }
/*buildSectionElementAsCore*/
    private void buildSectionElementAsCore(String name,String value,String sectionElementheader,integer rowID,integer colID,WrapperUISection  wus){
    
    try{
    
     WUIRenderComponentBuilderHelper  wuiBhelper= new WUIRenderComponentBuilderHelper ();
      SIVARElementList   sectionElementsList= wuiBhelper.filterWUIEleOnPosition(rowID,colID,wus.getChildElements('WrapperUIRenderSectionElement'));
        WrapperUIRenderSectionElement wuse= (WrapperUIRenderSectionElement ) sectionElementsList.getSIVARElements().firstSIVARElement();
      if(wuse!=null){
    if(wrc.ChildHeadersNeeded()){
       wuse.setHeader(sectionElementheader);
       }
       wuse.setName(name);
       wuse.setValue(value);
       wuse.setLabel(name);
       }else {
       wuse= new WrapperUIRenderSectionElement ();
      if(wrc.ChildHeadersNeeded()){
          wuse.setHeader(sectionElementheader);
      }
       wuse.setName(name);
       wuse.setValue(value);
       wuse.setLabel(name);
       wuse.setRowID(rowID);
       wuse.setColID(colID);
      
       wus.addWrapperUIRenderSectionElement(wuse);
       } 
       }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
               
            }
       }
       /*buildSectionElementAsCoreMap*/
           private void buildSectionElementAsCoreMap(String name,String value,String sectionElementheader,integer rowID,integer colID,WrapperUISection  wus){
    
    try{
    
     WUIRenderComponentBuilderHelper  wuiBhelper= new WUIRenderComponentBuilderHelper ();
             WrapperUIRenderSectionElement wuse= (WrapperUIRenderSectionElement )wuiBhelper.filterWUIEleMapOnKey(rowID,colID,wus.getChildElementsMap('WrapperUIRenderSectionElement'));
   //     WrapperUIRenderSectionElement wuse= (WrapperUIRenderSectionElement ) sectionElementsList.getSIVARElements().firstSIVARElement();
      if(wuse!=null){
    if(wrc.ChildHeadersNeeded()){
       wuse.setHeader(sectionElementheader);
       }
       wuse.setName(name);
       wuse.setValue(value);
       wuse.setLabel(name);
       }else {
       wuse= new WrapperUIRenderSectionElement ();
      if(wrc.ChildHeadersNeeded()){
          wuse.setHeader(sectionElementheader);
      }
       wuse.setName(name);
       wuse.setValue(value);
       wuse.setLabel(name);
       wuse.setRowID(rowID);
       wuse.setColID(colID);
      
       wus.addWrapperUIRenderSectionElementMap(rowID+'_'+colID,wuse);
       } 
       }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
                
            }
       }
}