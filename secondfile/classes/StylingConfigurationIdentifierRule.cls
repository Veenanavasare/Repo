public class StylingConfigurationIdentifierRule extends SIVARWrapperUIStylingRule {
public Model execute (Model si){
WrapperBE wbe= (WrapperBE)si;
WrapperUIRenderComponent wrc=(WrapperUIRenderComponent) wbe.getWrapperUIRenderComponent() ;
//system.debug('wrc component in StylingConfigurationIdentifierRule : '+wrc);
String flowID=wrc.getFlowID();
    System.debug('flowID returned is'+flowID);
        //System.debug("flowID returned is"+flowID);
        
SIVARConfigurationIdentifierHelper scih= new SIVARConfigurationIdentifierHelper(flowID,SIVARConfigIdentifierDataKey.STYLING_CONFIG_IMPL);
           SIVARElementList configurationList=scih.getConfiguration();
        wrc.setStylingConfigurationList(configurationList);
   // system.debug('sc cteated getStyleConfigurationList:'+configurationList);
    // system.debug(' wrc component to work upon is '+wrc);
     
//WUI_RC_UBBADD_StyleConfig  loader=new WUI_RC_UBBADD_StyleConfig('name_p',flowID,'sivarFlowIdentifier_p') ;
    //loader.loadStyleConfigElement(); 
return si;

}
}