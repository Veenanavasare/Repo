public class SIVARConfigurationIdentifier {
private static Map<String, ClassConfigData> configurationClassesMap= null;

private static SIVARConfigurationIdentifier maploader= null;

private SIVARConfigurationIdentifier(){
     system.debug(' configurationClassesMap is gwetting created again:'+configurationClassesMap);
    
    configurationClassesMap= new Map<String, ClassConfigData>();
     system.debug(' configurationClassesMap is created again:'+configurationClassesMap);
    
    
    loadSIVARConfigurationMap();
}






public static SIVARConfigurationIdentifier getInstance(){
    if(maploader==null){
    system.debug(' SIVARConfigurationIdentifier  is null:'+maploader);
        maploader= new SIVARConfigurationIdentifier ();
    }else{
        system.debug(' SIVARConfigurationIdentifier  is not null:'+maploader);

    }
    return maploader;
}





static void setClassConfigDataOnSet(String flowID,SIVARConfigIdentifierDataKey key, String value){
    ClassConfigData ccd1 =null;
            if(configurationClassesMap.get(flowID)==null){
                ccd1 =new ClassConfigData();
                configurationClassesMap.put(flowID, ccd1);
    }else {
        ccd1=configurationClassesMap.get(flowID);
    }
    ccd1.setConfigData(key, value);

}
private void loadSIVARConfigurationMap() {
    
    setClassConfigDataOnSet( '1',SIVARConfigIdentifierDataKey.STYLING_CONFIG_IMPL,'WUI_RC_UBBADD_StyleConfig');
 //   setClassConfigDataOnSet( '1',SIVARConfigIdentifierDataKey.CONFIGURATION_X_IMPL,'WUI_RC_UBB_CHANGE_Config');
    setClassConfigDataOnSet( '2',SIVARConfigIdentifierDataKey.STYLING_CONFIG_IMPL,'WUI_RC_UBB_CHANGE_StyleConfig');
    setClassConfigDataOnSet( '3',SIVARConfigIdentifierDataKey.STYLING_CONFIG_IMPL,'WUI_RC_UBB_REMOVE_StyleConfig');
    setClassConfigDataOnSet( '4',SIVARConfigIdentifierDataKey.STYLING_CONFIG_IMPL,'WUI_RC_PORT_SPEED_CHANGE_StyleConfig');
    
}
public String  getConfiguration(String flowID,SIVARConfigIdentifierDataKey configurationID){
    ClassConfigData ccd = configurationClassesMap.get(flowID);
    return ccd.getConfigData(configurationID);
     
    
}

}