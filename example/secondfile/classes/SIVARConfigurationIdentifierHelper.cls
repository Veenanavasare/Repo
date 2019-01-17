public class SIVARConfigurationIdentifierHelper{
String flowID='';
 SIVARConfigIdentifierDataKey confiIdentifierKey=null;
public SIVARConfigurationIdentifierHelper (String flowID_p, SIVARConfigIdentifierDataKey confiIdentifierKey_p){
flowID=flowID_p;
confiIdentifierKey=confiIdentifierKey_p;
}

public SIVARElementList getConfiguration(){
SIVARConfigurationIdentifier configIdentifier=SIVARConfigurationIdentifier.getInstance();
    String  configurationimpl=  configIdentifier.getConfiguration(flowID, SIVARConfigIdentifierDataKey.STYLING_CONFIG_IMPL);
    system.debug('configIdentifier'+configIdentifier);
    Type t=Type.forName(configurationimpl);
    SIVAR_WUI_RC_StyleConfig sc=(SIVAR_WUI_RC_StyleConfig)  t.newInstance();
  //  system.debug('sc cteated'+sc);
    SIVARElementList configurationList=     sc.getStyleConfigurationList();
 //   system.debug('sc cteated getStyleConfigurationList:'+configurationList);
    return configurationList;
}
}