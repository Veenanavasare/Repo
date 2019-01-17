public with sharing class SIVARElementMap implements FilterableList{
    
    private Map<String,SIVARElement> sivarEleMap;
    
    public integer itemMapType {get;set;}
    
    public SIVARElementMap()
    {
        sivarEleMap = new Map<String,SIVARElement>();
        
    }
    public SIVARElement get(String k){
    return sivarEleMap.get(k);
    }
    
    public Map<String,SIVARElement> getMap(){
     return    sivarEleMap;
    }
   public SIVARElementIterator iterator()
    {
        
        //;
        
        return new SIVARElementListIterator(sivarEleMap.values());
    }
    
    public void add(String id,SIVARElement item)
    {
        sivarEleMap.put(id,item);
    }
    
    public void remove(String index)
    {
        // check on implementation
        if(sivarEleMap.get(index)!=null){
            sivarEleMap.remove(index);
        }
    }
    
    public SIVARElement[] toArray()
    {
        //check implementation
        //   return (SIVARElement[]) sivarEleMap.toArray();
        return null;
        
    }
    
    public void add(SIVARElementMap otherMap)
    {
 //   Map<String,SivarElement>  map= otherMap.getMap();
// Map<String,SivarElement>  map;
        Iterator<String> iter = otherMap.getMap().keySet().iterator();
        
        while(iter.hasNext())
        {
            String k=iter.next();
            SIVARElement bi = (SIVARElement)otherMap.get(k);
            this.sivarEleMap.put(k,bi);
        }
    }
    
     public void add(Map<String,SIVARElement> otherMap)
    {
    //  Map<String,SIVARElement> map=       otherMap.getMap();

        Iterator<String> iter = otherMap.keySet().iterator();
        
        while(iter.hasNext())
        {String k=iter.next();
            SIVARElement bi = (SIVARElement)otherMap.get(k);
            this.sivarEleMap.put(k,bi);
        }
    }
/**    public SIVARElement getWorkflowNetElements(String businessCode)
    {
        Iterator<SIVARElement> iter = sivarEleMap.iterator();
        SIVARElement bundle = null;
        while(iter.hasNext())
        {
            SIVARElement bi = (SIVARElement)iter.next();
            //
            //         if (businessCode.equals(bi.getSKU()))
            //         {
            //            bundle = bi;
            //            break;
            //         }
        }
        return bundle;
    }**/
    
    
   public SIVARElement firstSIVARElement()
    {
        SIVARElement item = null;
        if(sivarEleMap.size()>0){
       item = (SIVARElement)sivarEleMap.values().get(0);
        }
        return item;
    }
    
    
    public integer size()
    {
        return sivarEleMap.size();
    }
    
    
    public override  String toString()
    {
        String[] returnValue =new String [0];
        Set<String> keys=sivarEleMap.keySet();
        
        Iterator<String> iter = keys.iterator();
        returnValue.add('<SIVARElementMap>'); 
           returnValue.add('<map>');
        while(iter.hasNext())
        {
            returnValue.add('<ele>');
        String key=iter.next();
            SIVARElement item = sivarEleMap.get(key);
            returnValue.add('<key>');
            returnValue.add(key);
            returnValue.add('</key>');
            returnValue.add('<value>');
            returnValue.add(item+'');
             returnValue.add('</value>');
                         returnValue.add('</ele>');
            //         returnValue.append(" , ");
        }
        //  returnValue.append("<billingAccountNumber>" + billingAccountNumber);
        //returnValue.append("</billingAccountNumber>");
           returnValue.add('</map>');
        /**UN COMMENT as needed**/
        returnValue.add('<itemMapType>' + itemMapType);
        returnValue.add('</itemMapType>');
        returnValue.add('</SIVARElementMap>');
         String returnValueStr= String.join(returnValue, ' ');
        return returnValueStr;
    }
    
    public Map<String,SIVARElement> getSIVARElementMap()
    {
        return sivarEleMap;
    }
    
    
    SivarElementList l= new SivarElementList();
    //supposedly, filtered items will be returned back..
    //This is the method implementation from the FilterableList interface
    public SIVARElementList getSIVARElements()
    {
    List<SivarElement> sl=sivarEleMap.values();
    l.add(sl);
        
        return l;
    }
    

    public class SIVARElementListIterator
        implements SIVARElementIterator
    {    
       
        Iterator<SIVARElement> iter = null;
        List<SIVARElement> elements;
        private integer currentIndex = -1;
        
        // Iterator iter;
        
        public SIVARElementListIterator(List<SIVARElement> coll)
        {
            this.iter = coll.iterator();
            elements = coll;
        }
        
        public boolean hasNext()
        {
            return iter.hasNext();
        }
        
        public SIVARElement next()
        {
            SIVARElement bi = (SIVARElement)iter.next();
            currentIndex++;
            return bi;
        }
        
        public void remove()
        {
            // check for implementation
           
            if(elements != null && elements.size() > 0){
                if(-1 < currentIndex  && currentIndex < elements.size()){
                    elements.remove(--currentIndex);
                }
            }
        }
    }
    public boolean isEndDated(String bizCode)
    {
        return false;
    }
    
    
    /**  public void sort(Comparator c)
{
if ( (c != null) && (sivarEleMap!= null) )
{
Collections.sort(sivarEleMap, c);
}
} */
    
    /**
* @return
* @uml.property  name="itemMapType"
*/
    public integer getSIVARElementMapType()
    {
        return itemMapType;
    }
    
    public boolean contains(SIVARElement item)
    {
        //check for implementation
        boolean found = false;
        for(SIVARElement elem : sivarEleMap.values()){
            if(item == elem){
                found = true;
                break;
            }
        }
        return  found;
    }
}