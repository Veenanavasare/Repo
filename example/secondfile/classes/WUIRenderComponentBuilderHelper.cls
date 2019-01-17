public class WUIRenderComponentBuilderHelper {
/*public SIVARElementList    filterWUIEleOnName(String filtercriteria, List<Wrapper_UI_Element> wuiElement){
SIVARElementList sel= new SIVARElementList ();
 sel.add(wuiElement);
 WrapperUIElementNameFilter snfilter= new WrapperUIElementNameFilter (sel,filtercriteria);
return snfilter.getSIVARElements();
}*/
public SIVARElementList    filterWUIEleOnName(String filtercriteria, SIVARElementList wuiElement){
 WrapperUIElementNameFilter snfilter= new WrapperUIElementNameFilter (wuiElement,filtercriteria);
return snfilter.getSIVARElements();
}


public SIVARElementList    filterWUIEleOnPosition(integer rowID,integer colID, SIVARElementList  sel){

// system.debug('wuiElement before applying filter of row'+rowID+' and colID:'+colID+' is:'+wuiElement);
 WrapperUIElementPositionFilter snfilter= new WrapperUIElementPositionFilter (sel,rowID,colID);
return snfilter.getSIVARElements();
}

public SIVARElement    filterWUIEleMapOnKey(integer rowID,integer colID, SIVARElementMap  sel){
return sel.get(rowID+'_'+colID);

/**if(sel.get(sectionHeader)==null){
    
}**/
// system.debug('wuiElement before applying filter of row'+rowID+' and colID:'+colID+' is:'+wuiElement);
 //WrapperUIElementPositionFilter snfilter= new WrapperUIElementPositionFilter (sel,rowID,colID);
//return snfilter.getSIVARElements();
}
}