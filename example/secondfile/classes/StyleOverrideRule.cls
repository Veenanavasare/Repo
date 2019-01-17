public class StyleOverrideRule extends SIVARWrapperUIStylingRule {
    
    
    
public  Model execute (Model si){
SIVARElementList configurationList= (SIVARElementList)si;
  SIVARConfigurationBasedFilter  scbf= new SIVARConfigurationBasedFilter (configurationList,SIVARConfigIdentifierDataKey.OVERRIDING_ENABLE,'true');
//applying filter to indentify override as true.

//system.debug('after aplying  STYLE_OVERRIDE_RULE SIVARConfigurationBasedFilter filter :OVERRIDING_ENABLE'+scbf.getSIVARElements());
return scbf.getSIVARElements();

}
}