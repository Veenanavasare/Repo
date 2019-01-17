public abstract class SIVARConfigData implements SIVARConfigurationElement{
    Map<SIVARConfigIdentifierDataKey,String> cofigDataMap=null;
public  SIVARConfigData(){
        cofigDataMap=new Map<SIVARConfigIdentifierDataKey, String>();
    }
    
public void setConfigData(SIVARConfigIdentifierDataKey configDataKey,String value){
        cofigDataMap.put(configDataKey, value);
    }

public String   getConfigData(SIVARConfigIdentifierDataKey configDataKey){
    return cofigDataMap.get(configDataKey);
}


public override virtual String toString()
    {
        String[] returnValue =new String [0];
        
        
        returnValue.add('<SIVARConfigData>');
        
        Set<SIVARConfigIdentifierDataKey> keyset = cofigDataMap.keySet();
        for (SIVARConfigIdentifierDataKey key : keyset  ){
           // system.debug('keyis:'+key);
             returnValue.add('<');
             returnValue.add(key.name());
             returnValue.add('>');
                 returnValue.add(cofigDataMap.get(key ));
             returnValue.add('</');
             returnValue.add(key.name());
             returnValue.add('>');
        }
       /* returnValue.add('<keyis>' + name);
        returnValue.add('</name>');  returnValue.add('<label>' + label);
        returnValue.add('</label>');  returnValue.add('<type>' + type);
        returnValue.add('</type>');  
returnValue.add('<header>' + header.getName());
        returnValue.add('</header>');
        returnValue.add('<colID>' + this.getColID());
        returnValue.add('</colID>');  
        returnValue.add('<rowID>' + this.getRowID());
        returnValue.add('</rowID>');  
        returnValue.add('<WrapperUISectionList>' + wuirSEList );
        returnValue.add('</WrapperUISectionList>');*/
         returnValue.add('</SIVARConfigData>');
        String returnValueStr= String.join(returnValue, ' ');
        return returnValueStr;
    }

}