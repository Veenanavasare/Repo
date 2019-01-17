public class SIVARConfigurationBasedFilter extends FilterExecutionModel{

    private String configValue ;
    private SIVARConfigIdentifierDataKey configDataKey;

    public SIVARConfigurationBasedFilter(FilterableList sivarlist,SIVARConfigIdentifierDataKey configDataKey_p,String configValue_p) {
        super(sivarlist);
        configDataKey = configDataKey_p;
        configValue = configValue_p;
     
        }
    protected override boolean apply(SIVARElement item) {
        
       SIVARConfigData scd=(SIVARConfigData)item;
      // system.debug('configDataKey:'+configDataKey+'configValue:'+configValue+'SIVARConfigurationBasedFilter  scd is:'+scd);
       String condfigdata=scd.getConfigData(configDataKey);
       if(condfigdata==null){
          system.debug('condfigdata is null:condfigdata:'+condfigdata+' for KEY:configDataKey:'+configDataKey+' configValue:'+configValue);
        
       }  boolean b=condfigdata.equals(configValue);
      //  system.debug('returning boolean:'+b+' for condfigdata:'+condfigdata+' configValue:'+configValue);
        return  b;
           }
}