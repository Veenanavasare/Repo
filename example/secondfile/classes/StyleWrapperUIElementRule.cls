public class StyleWrapperUIElementRule extends SIVARWrapperUIStylingRule {

List<String> e2atForChildCheckList=null;
boolean checkforOWNStyle=true;
public StyleWrapperUIElementRule (List<String> e2atForChildCheck_p) {
e2atForChildCheckList=e2atForChildCheck_p;
checkforOWNStyle=false;

}
// use this to apply UI elements own stylings.
public StyleWrapperUIElementRule() {

}
public  Model execute (Model si){
      try{
WrapperUIGridElemnt  wrc= (WrapperUIGridElemnt )si;
//// system.debug('WrapperUIRenderSectionElementLog '+wrc.getName()+'  WrapperUIGridElemnt   component   : '+wrc);
SIVARElementList configurationList= wrc.getStylingConfigurationList();
// --> uc later system.debug('WrapperUIRenderSectionElementLog '+wrc.getName()+'  under test    getStyleConfigurationList:'+configurationList.size());
// TODO TEST LINE wrc.applyStyle('rc componet style to test append');
//String flowID=wrc.getFlowID();
    
  //s wrc. 
//system.debug('WrapperUIRenderSectionElementLog '+wrc.getName()+'2  under testafter aplying  StyleWrapperUIElementRule_Clone filter :'+wrc);
    String myStr     = String.valueOf(wrc);
String classNamex = myStr.split('>')[0].split('<')[1];
String  className=classNamex.trim();
   // --> uc later 
  //system.debug('2  under testclassName is:'+className+wrc.getName());
//if(className.equals('WrapperUIRenderSectionElement'))  system.debug('WrapperUIRenderSectionElementLog '+wrc.getName()+'  under testclassName is:'+className);   
SIVARConfigurationBasedFilter  overridingStyleConfigsFilter= new SIVARConfigurationBasedFilter (configurationList,SIVARConfigIdentifierDataKey.OVERRIDING_ENABLE,'true');

//if(className.equals('WrapperUIRenderSectionElement')) system.debug('WrapperUIRenderSectionElementLog '+wrc.getName()+'  under testoriginal configurationlist size:'+configurationList.getSIVARElements().size());//+configurationList.getSIVARElements());
  
  //  SIVARElementList orlist= overridingStyleConfigsFilter.getSIVARElements();
  // --> uc later 
  //if(className.equals('WrapperUIRenderSectionElement'))  system.debug('WrapperUIRenderSectionElementLog '+wrc.getName()+'  under testconfigurationList/overridingConfiglist size:'+':'+overridingStyleConfigsFilter.getSIVARElements().size());

SIVARConfigurationBasedFilter  scbf= new SIVARConfigurationBasedFilter (overridingStyleConfigsFilter,SIVARConfigIdentifierDataKey.LEVEL,className);

//applying filter to indentify configurations to be applied to the current level of class.
SIVARElementList atlevelApplList=scbf.getSIVARElements();

 // --> uc later
  //if(className.equals('WrapperUIRenderSectionElement'))  system.debug('WrapperUIRenderSectionElementLog '+wrc.getName()+'  under testconfigurationList/overridingConfiglist/atlevelApplList size'+atlevelApplList.size());

//applying filter to indentify configurations at current level of class to apply to itself or to its subcomponents.
SIVARConfigurationBasedFilter  selfNameStyleFilter= new SIVARConfigurationBasedFilter (scbf,SIVARConfigIdentifierDataKeyHelper.valueOf(className+'_Name'),wrc.getName());


//applying filter to indentify configurations at current level of class to apply to itself or to its subcomponents.
SIVARConfigurationBasedFilter  applytoSelfFilter= new SIVARConfigurationBasedFilter (selfNameStyleFilter,SIVARConfigIdentifierDataKey.APPLY_TO_SELF,'true');
  
  
  
  if(checkforOWNStyle==true){
   // --> uc later
 // if(className.equals('WrapperUIRenderSectionElement'))   system.debug('WrapperUIRenderSectionElementLog '+wrc.getName()+'  under testconfigurationList/overridingConfiglist/atlevelApplList/applytoSelf size'+applytoSelfFilter.getSIVARElements().size());
//
 // if(className.equals('WrapperUIRenderSectionElement')) system.debug('WrapperUIRenderSectionElementLog '+wrc.getName()+'  under test after aplying  SIVARConfigurationBasedFilter filter in StyleWrapperUIElementRule_Clone  for level'+className+' to check apply to self>'+applytoSelfFilter.getSIVARElements()+ '</after aplying  SIVARConfigurationBasedFilter filter in StyleWrapperUIElementRule_Clone  for level'+className+' to check apply to self>');
    
    
//for all configurations qualifying in apply to self at this level, apply configuration to the component. 
////
 // if(className.equals('WrapperUIRenderSectionElement'))  system.debug('WrapperUIRenderSectionElementLog '+wrc.getName()+' grid element before applying styling:'+wrc);
// if append to style is on apply append to .. or over ride. 
SIVARConfigurationBasedFilter  appendToStyleFilter= new SIVARConfigurationBasedFilter (applytoSelfFilter,SIVARConfigIdentifierDataKey.APPEND_TO_STYLING,'true');
SIVARElementList    appendtoselfStyles=appendToStyleFilter.getSIVARElements();
     // --> uc later  
 // if(className.equals('WrapperUIRenderSectionElement'))   system.debug('WrapperUIRenderSectionElementLog '+wrc.getName()+'  under testconfigurationList/overridingConfiglist/atlevelApplList/applytoSelf/appendtoselfStyles size'+appendtoselfStyles.size());

    SIVARElementIterator  itr=appendtoselfStyles.iterator();
    while (itr.hasNext()){
        SIVARConfigData  styleconfig=(SIVARConfigData)itr.next();
    
       
       
      
    
     // --> uc later  
 // if(className.equals('WrapperUIRenderSectionElement'))  system.debug('WrapperUIRenderSectionElementLog '+wrc.getName()+'  under test Applying styling appending: '+styleconfig);
       String style=styleconfig.getConfigData(SIVARConfigIdentifierDataKeyHelper.valueof(className+'_Styling'));
 //   
 // if(className.equals('WrapperUIRenderSectionElement'))    system.debug('WrapperUIRenderSectionElementLog '+wrc.getName()+' 50 StyleWrapperUIElementRule_Clone style to apply is:'+style);
        String existingstyle=wrc.getStyle();
       
     // 
 // if(className.equals('WrapperUIRenderSectionElement'))    system.debug(className+wrc.getName()+'ut before appending style:'+wrc.getStyle());
        if((existingstyle!=null) && (existingstyle.trim().length()>0) ){
       
           style=existingstyle+style;
        } 
     //  
 // if(className.equals('WrapperUIRenderSectionElement'))  system.debug('WrapperUIRenderSectionElementLog '+wrc.getName()+' style before application is'+style);
        wrc.applyStyle(style);
         WrapperUIElementHeader header=(WrapperUIElementHeader)wrc.getChildElements('WrapperUIElementHeader').firstSIVARElement();
        if(header!=null){
        String headerStyle=styleconfig.getConfigData(SIVARConfigIdentifierDataKeyHelper.valueof(className+'_Header_Styling'));
       String existingHeaderStyle=header.getStyle();
        if((existingHeaderStyle!=null) && (existingHeaderStyle.trim().length()>0) ){
       
           
          headerStyle=existingHeaderStyle+headerStyle;
        } 
         header.applyStyle(headerStyle);
       }
        
   //  
//  if(className.equals('WrapperUIRenderSectionElement'))    system.debug('WrapperUIRenderSectionElementLog '+wrc.getName()+' 54 StyleWrapperUIElementRule_Clone wrc after applying current style'+wrc);
    }
    // --> uc later   system.debug(className+wrc.getName()+'ut after completing appending style:'+wrc.getStyle());
    
    
  // flipped to get the override styles of child data data
  appendToStyleFilter.flip(true);

 
     SIVARElementList  overrideStyles=appendToStyleFilter.getSIVARElements();
     
      SIVARElementIterator  ositr=overrideStyles.iterator();
    while (ositr.hasNext()){
        SIVARConfigData  styleconfig=(SIVARConfigData)ositr.next();
   //   system.debug('WrapperUIRenderSectionElementLog '+wrc.getName()+'  under testApplying styling in override fashion:'+styleconfig);
       String style=styleconfig.getConfigData(SIVARConfigIdentifierDataKeyHelper.valueof(className+'_Styling'));
       WrapperUIElementHeader header=(WrapperUIElementHeader )wrc.getChildElements('WrapperUIElementHeader').firstSIVARElement();
    if(header!=null){   
       String headerStyle=styleconfig.getConfigData(SIVARConfigIdentifierDataKeyHelper.valueof(className+'_Header_Styling'));
        header.applyStyle(headerStyle);  
    }
        wrc.applyStyle(style);
    }
    
    
   // --> uc later
 // if(className.equals('WrapperUIRenderSectionElement'))    system.debug(className+wrc.getName()+'ut after completing overriding style:'+wrc.getStyle());
    
  }else{
 
  
  
    //flip apply to self to identified if anything thats not set as appyl to self is set for applyto child. 
    
    applytoSelfFilter.flip(true);
    SIVARElementList probablConfigstoChild =    applytoSelfFilter.getSIVARElements();
  // --> uc later
 // if(className.equals('WrapperUIRenderSectionElement'))       system.debug(className+wrc.getName()+'ut following configs probablConfigstoChild atthis level to its child:'+probablConfigstoChild.size());//+probablConfigstoChild);
    
    //filter for WrapperUISection .
      /* ************************************** 
    IMPLEMENTED FOR 1 child Element
    **************************************************/  
    if(e2atForChildCheckList!=null){
 Iterator<String> e2atForChildCheckItr= e2atForChildCheckList.iterator();

    while (e2atForChildCheckItr.hasNext()){
    String e2atForChildCheck=e2atForChildCheckItr.next();
    // for every child get the configuration to apply to that child
    SIVARConfigurationBasedFilter  forwuisecConfigs= new SIVARConfigurationBasedFilter (probablConfigstoChild,SIVARConfigIdentifierDataKey.ELEMENT_TO_APPLY_TO,e2atForChildCheck);
    SIVARElementList wuisecConfiglist=forwuisecConfigs.getSIVARElements();
        // for every child get the list of thoes types of childs from the wui-elements
    SIVARElementList wrapperUIList= wrc.getChildElements (e2atForChildCheck);
    SIVARElementIterator    wuiitr=wrapperUIList.iterator();

    // check if the style is suppsoed to be applied for all then apply for all of it. 
    SIVARConfigurationBasedFilter  wuisecSpecificAllCheckConfigs= new SIVARConfigurationBasedFilter (wuisecConfiglist,SIVARConfigIdentifierDataKeyHelper.valueOf(e2atForChildCheck+'_Name'),'ALL');
    SIVARElementList   wuiConfigsforall=wuisecSpecificAllCheckConfigs.getSIVARElements();
    
    //Apply style configuration for all   
    if(wuiConfigsforall.size()>0){
   while (wuiitr.hasNext()){
        WrapperUIGridElemnt wrapperUIEle=(WrapperUIGridElemnt)wuiitr.next();
        wrapperUIEle.setStylingConfigurationList(wuiConfigsforall);
       InheritUIStyleFromParentRule inheritStylerule=new InheritUIStyleFromParentRule ();
       inheritStylerule.execute(wrapperUIEle);
      }
    }
  
   //apply style configuration at specific level    
   wuisecSpecificAllCheckConfigs.flip(true);
    
     SIVARElementList   wuisecSpecificConfigs2=wuisecSpecificAllCheckConfigs.getSIVARElements();
    
    if(wuisecSpecificConfigs2.size()>0){
    //check if the list needed to be recopied
    SIVARElementIterator    wuiaitr2=wrapperUIList.iterator();
     while (wuiaitr2.hasNext()){
     WrapperUIGridElemnt  wrapperUISection=(WrapperUIGridElemnt)wuiaitr2.next();
     String sectionName =wrapperUISection.getName();
     //filter configuration for that specific name of element
     SIVARConfigurationBasedFilter  wuisecSpecificConfigs= new SIVARConfigurationBasedFilter (wuisecSpecificConfigs2,SIVARConfigIdentifierDataKeyHelper.valueOf(e2atForChildCheck+'_Name'),sectionName );
      wrapperUISection.setStylingConfigurationList(wuisecSpecificConfigs.getSIVARElements());
    InheritUIStyleFromParentRule inheritStylerule=new InheritUIStyleFromParentRule ();
         inheritStylerule.execute(wrapperUISection);
     }
    }else{
   // --> uc later 
 // if(className.equals('WrapperUIRenderSectionElement'))      system.debug('WrapperUIRenderSectionElementLog '+wrc.getName()+'  under testnone of the configurations are section specific hence doing nothing');
    } /**/
    }
  }
    
  } //
//  if(className.equals('WrapperUIRenderSectionElement'))  system.debug('WrapperUIRenderSectionElementLog '+wrc.getName()+' wrc at the end of StyleWrapperUIElementRule_Clone :'+wrc);
  }catch(Exception e){
     system.debug('Exception captured in StyleWrapperUIElementRule_Clone:'+e);
    throw e;
    }
    
return si;

}
}