public class InheritUIStyleFromParentRule extends SIVARWrapperUIStylingRule {
public  Model execute (Model si){
    
WrapperUIGridElemnt wrc= (WrapperUIGridElemnt )si;
    
////system.debug('wrc component in InheritUIStyleFromParentRule : '+wrc);
SIVARElementList configurationList= wrc.getStylingConfigurationList();
   // wrc.
    //system.debug(wrc.getName()+' :configurationList OBTAINED FOR inheretance is:'+configurationList);
////system.debug('sc cteated getStyleConfigurationList:'+configurationList.size());
//wrc.applyStyle('wuisection componet style to test append in inherit'+wrc.getName());
//String flowID=wrc.getFlowID();
    
  //s wrc. 
////system.debug('after aplying  InheritUIStyleFromParentRule filter :'+wrc);
    String myStr     = String.valueOf(wrc);
String classNamex1 = myStr.split('>')[0].split('<')[1];

String classNamex=classNamex1.trim();
    
SIVARConfigurationBasedFilter  overridingStyleConfigsFilter= new SIVARConfigurationBasedFilter (configurationList,SIVARConfigIdentifierDataKey.OVERRIDING_ENABLE,'true');

    //system.debug('original configurationlist size:'+configurationList.getSIVARElements().size());

  
    //system.debug('configurationList/overridingConfiglist size:'+':'+overridingStyleConfigsFilter.getSIVARElements().size());


SIVARConfigurationBasedFilter  scbf= new SIVARConfigurationBasedFilter (overridingStyleConfigsFilter,SIVARConfigIdentifierDataKey.ELEMENT_TO_APPLY_TO,classNamex);

//applying filter to indentify configurations to be applied to the current level of class.
SIVARElementList elementTOApplyTOself=scbf.getSIVARElements();
/*SIVARConfigData scd= (SIVARConfigData)elementTOApplyTOself.getSIVARElements().firstSIVARElement();
if(scd.getConfigData(SIVARConfigIdentifierDataKey.ELEMENT_TO_APPLY_TO).equals(classNameX)){
//system.debug('Both names are equal');
}else{
//system.debug('Both names are not equal');

} */
//system.debug('configurationList/overridingConfiglist/elementTOApplyTOself size for calss:'+':'+elementTOApplyTOself.size());

//applying filter to indentify configurations at current level of class to apply to itself or to its subcomponents.
//SIVARConfigurationBasedFilter  applytoSelfFilter= new SIVARConfigurationBasedFilter (scbf,SIVARConfigIdentifierDataKey.APPLY_TO_SELF,'true');
  
  //  //system.debug('configurationList/overridingConfiglist/atlevelApplList/applytoSelf size'+applytoSelfFilter.getSIVARElements().size());
////system.debug('<after aplying  SIVARConfigurationBasedFilter filter in InheritUIStyleFromParentRule  for level'+className+' to check apply to self>'+applytoSelfFilter.getSIVARElements()+ '</after aplying  SIVARConfigurationBasedFilter filter in InheritUIStyleFromParentRule  for level'+className+' to check apply to self>');
    
    
//for all configurations qualifying in apply to self at this level, apply configuration to the component. 
////system.debug('grid element before applying styling:'+wrc);
// if append to style is on apply append to .. or over ride. 
SIVARConfigurationBasedFilter  appendToStyleFilter= new SIVARConfigurationBasedFilter (elementTOApplyTOself,SIVARConfigIdentifierDataKey.APPEND_TO_STYLING,'true');
SIVARElementList    appendtoselfStyles=appendToStyleFilter.getSIVARElements();
       //system.debug('configurationList/overridingConfiglist/atlevelApplList/applytoSelf/appendtoselfStyles size'+appendtoselfStyles.size());

   SIVARElementIterator  itr=appendtoselfStyles.iterator();
    while (itr.hasNext()){
        SIVARConfigData  styleconfig=(SIVARConfigData)itr.next();
       //system.debug('Applying styling in appending fashion:'+styleconfig);
       String style=styleconfig.getConfigData(SIVARConfigIdentifierDataKeyHelper.valueOf(classNamex+'_Styling'));
        String existingstyle=wrc.getStyle();
         if((existingstyle!=null) && (existingstyle.trim().length()>0) ){
       
           style=existingstyle+style;
          
        } 
       // system.debug('style before application is'+style);
        wrc.applyStyle(style);
  WrapperUIElementHeader header=(WrapperUIElementHeader)wrc.getChildElements('WrapperUIElementHeader').firstSIVARElement();
        if(header!=null){
        String headerStyle=styleconfig.getConfigData(SIVARConfigIdentifierDataKeyHelper.valueof(classNamex+'_Header_Styling'));
       String existingHeaderStyle=header.getStyle();
        if((existingHeaderStyle!=null) && (existingHeaderStyle.trim().length()>0) ){
       
           
          headerStyle=existingHeaderStyle+headerStyle;
        } 
         header.applyStyle(headerStyle);
    //    system.debug('54 InheritUIStyleFromParentRule wrc after applying current header style'+wrc);
 
       }
        
    }
    

  appendToStyleFilter.flip(true);
     SIVARElementList  overrideStyles=appendToStyleFilter.getSIVARElements();
      SIVARElementIterator  ositr=overrideStyles.iterator();
    while (ositr.hasNext()){
        SIVARConfigData  styleconfig=(SIVARConfigData)ositr.next();
     //system.debug('Applying styling in override fashion:'+styleconfig);
    
         String style=styleconfig.getConfigData(SIVARConfigIdentifierDataKeyHelper.valueof(classNamex+'_Styling'));
       WrapperUIElementHeader header=(WrapperUIElementHeader )wrc.getChildElements('WrapperUIElementHeader').firstSIVARElement();
    if(header!=null){   
       String headerStyle=styleconfig.getConfigData(SIVARConfigIdentifierDataKeyHelper.valueof(classNamex+'_Header_Styling'));
        header.applyStyle(headerStyle);  
    }
        wrc.applyStyle(style);
    }
    
       //system.debug('wrc at end of inheretence rule'+wrc);

    
return si;

}
}