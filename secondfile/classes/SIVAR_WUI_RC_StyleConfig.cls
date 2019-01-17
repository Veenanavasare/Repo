public abstract class SIVAR_WUI_RC_StyleConfig extends SIVARStyleConfig {

SIVARElementList styleConfigurationList;
private String name;
private String flowID;
private String sivarFlowIdentifier;
public SIVAR_WUI_RC_StyleConfig(String name_p,String flowID_p,String sivarFlowIdentifier_p){
    styleConfigurationList= new SIVARElementList();
    name=name_p;
    flowID=flowID_p;
    sivarFlowIdentifier=sivarFlowIdentifier_p;
}

public SIVARElementList getStyleConfigurationList(){
return styleConfigurationList;
}
public SIVAR_WUI_RC_StyleConfig(){
    styleConfigurationList= new SIVARElementList();
    
}
public abstract void loadStyleConfigElement();

public  void loadStyleConfigElement(String name,String flowID,String SIVARFlowIdentifier,String Level,boolean Apply_to_self,boolean Apply_to_all_child,String ELEMENTtoApplyto, String RenderComponent,String Section,String SectionElement,String Grid_Element,String RC_Styling,String RC_Header_Styling,String Section_Styling,String Section_Header_Styling,String SE_Styling,String SE_Header_Styling,String GE_Styling,String GE_Label_Styling,String GA_Value_Styling,String StyleOverrideRule,boolean Append_To_Styling,boolean Over_ride_Styling) 
{
 //SIVARStyleConfigData ssce= new SIVAR_WUI_RC_StyleConfigData(Name,FlowID,SIVARFlowIdentifier,Level,Apply_to_self,Apply_to_all_child,ELEMENTtoApplyto,RenderComponent,Section,SectionElement,Grid_Element,RC_Styling,Section_Styling,Section_Header_Styling,SE_Styling,SE_Header_Styling,GE_Label_Styling,GA_Value_Styling,StyleOverrideRule,Append_To_Styling,Over_ride_Styling);
 SIVARConfigDataRefRepository scdrr= new SIVARConfigDataRefRepository();
 String id=flowID;

//system.debug('loading configuration data to lisst for name:'+name);

SIVARConfigData value2= new SIVARStyleConfigData();
value2.setConfigData(SIVARConfigIdentifierDataKey.NAME, name);
value2.setConfigData(SIVARConfigIdentifierDataKey.FLOW_ID, flowID);
value2.setConfigData(SIVARConfigIdentifierDataKey.SIVAR_FLOW_IDENTIFIER, SIVARFlowIdentifier);
value2.setConfigData(SIVARConfigIdentifierDataKey.LEVEL, Level);
value2.setConfigData(SIVARConfigIdentifierDataKey.APPLY_TO_SELF, Apply_to_self+'');
value2.setConfigData(SIVARConfigIdentifierDataKey.APPLY_TO_ALL_CHILD, Apply_to_all_child+'');
value2.setConfigData(SIVARConfigIdentifierDataKey.ELEMENT_TO_APPLY_TO, ELEMENTtoApplyto);
value2.setConfigData(SIVARConfigIdentifierDataKey.WUI_RENDER_COMPONENT, RenderComponent);
value2.setConfigData(SIVARConfigIdentifierDataKey.WUI_SECTION, Section);
value2.setConfigData(SIVARConfigIdentifierDataKey.WUI_SECTION_ELEMENT, SectionElement);
value2.setConfigData(SIVARConfigIdentifierDataKey.WUI_GRID_ELEMENT, Grid_Element);
value2.setConfigData(SIVARConfigIdentifierDataKey.WUI_RC_STYLING, RC_Styling);
value2.setConfigData(SIVARConfigIdentifierDataKey.WUI_RC_HEADER_STYLING, RC_Header_Styling);
value2.setConfigData(SIVARConfigIdentifierDataKey.WUI_SECTION_STYLING, Section_Styling);
value2.setConfigData(SIVARConfigIdentifierDataKey.WUI_SECTION_HEADER_STYLING, Section_Header_Styling);
value2.setConfigData(SIVARConfigIdentifierDataKey.WUI_SECTION_ELEMENT_STYLING, SE_Styling);
value2.setConfigData(SIVARConfigIdentifierDataKey.WUI_SECTION_ELEMENT_HEADER_STYLING, SE_Header_Styling);

value2.setConfigData(SIVARConfigIdentifierDataKey.WUI_GRID_ELEMENT_STYLING, GE_Styling);
value2.setConfigData(SIVARConfigIdentifierDataKey.WUI_GRID_ELEMENT_LABEL_STYLING, GE_Label_Styling);
value2.setConfigData(SIVARConfigIdentifierDataKey.WUI_GRID_ELEMENT_VALUE_STYLING, GA_Value_Styling);
value2.setConfigData(SIVARConfigIdentifierDataKey.STYLE_OVERRIDE_RULE, StyleOverrideRule);
value2.setConfigData(SIVARConfigIdentifierDataKey.APPEND_TO_STYLING, Append_To_Styling+'');
value2.setConfigData(SIVARConfigIdentifierDataKey.OVERRIDING_ENABLE, Over_ride_Styling+'');


styleConfigurationList.add(value2);


//system.debug('stylingConfiguration list after loading:'+styleConfigurationList);

scdrr.addSIVARConfiguration(id, value2);
}
}