public class WrapperUIElementNameFilter extends FilterExecutionModel 
{
    
private String name;

public WrapperUIElementNameFilter (FilterableList sivarlist,String namep) {
    super(sivarlist);
    name=namep;
 
    }
protected override boolean apply(SIVARElement item) {
    //
    Wrapper_UI_Element wuisec=(Wrapper_UI_Element ) item;
    if(name==null){
    return false;
    }else {
    return name.equals(wuisec.getName());
    }
}
}