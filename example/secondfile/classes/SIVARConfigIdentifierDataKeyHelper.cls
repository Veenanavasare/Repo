public class SIVARConfigIdentifierDataKeyHelper {
private static Map<String,SIVARConfigIdentifierDataKey> stringToEnum  = new Map<String,SIVARConfigIdentifierDataKey>();


static {

stringToEnum.put('WrapperUISection_Name',SIVARConfigIdentifierDataKey.WUI_SECTION);
stringToEnum.put('WrapperUISection_Styling',SIVARConfigIdentifierDataKey.WUI_SECTION_STYLING);
stringToEnum.put('WrapperUISection_Header_Styling',SIVARConfigIdentifierDataKey.WUI_SECTION_HEADER_STYLING);

stringToEnum.put('WrapperUIRenderSectionElement_Name',SIVARConfigIdentifierDataKey.WUI_SECTION_ELEMENT);
stringToEnum.put('WrapperUIRenderSectionElement_Styling',SIVARConfigIdentifierDataKey.WUI_SECTION_ELEMENT_STYLING);
stringToEnum.put('WrapperUIRenderSectionElement_Header_Styling',SIVARConfigIdentifierDataKey.WUI_SECTION_ELEMENT_HEADER_STYLING);

stringToEnum.put('WrapperUIRenderComponent_Name',SIVARConfigIdentifierDataKey.WUI_RENDER_COMPONENT);
stringToEnum.put('WrapperUIRenderComponent_Styling',SIVARConfigIdentifierDataKey.WUI_RC_STYLING);
stringToEnum.put('WrapperUIRenderComponent_Header_Styling',SIVARConfigIdentifierDataKey.WUI_RC_HEADER_STYLING);

stringToEnum.put('WrapperUIGridElemnt_Name',SIVARConfigIdentifierDataKey.WUI_GRID_ELEMENT);
stringToEnum.put('WrapperUIGridElemnt_Styling',SIVARConfigIdentifierDataKey.WUI_GRID_ELEMENT_STYLING);

}
public static SIVARConfigIdentifierDataKey valueOf(String enumName){
 
 return stringToEnum.get(enumName);
 }
}