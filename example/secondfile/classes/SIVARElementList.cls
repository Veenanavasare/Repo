public with sharing class SIVARElementList implements FilterableList{
    
    private List<SIVARElement> sivarEleList;
    
    public integer itemListType {get;set;}
    
    public SIVARElementList()
    {
        sivarEleList = new list<SIVARElement>();
        
    }
    
    
    public SIVARElementIterator iterator()
    {
        return new SIVARElementListIterator(sivarEleList);
    }
    
    public void add(SIVARElement item)
    {
        sivarEleList.add(item);
    }
    
    public void remove(integer index)
    {
        // check on implementation
        if(-1 < index  && index < sivarEleList.size()){
            sivarEleList.remove(index);
        }
    }
    
    public SIVARElement[] toArray()
    {
        //check implementation
        //   return (SIVARElement[]) sivarEleList.toArray();
        return null;
        
    }
    public void add(SIVARElementList otherList)
    {
        SIVARElementIterator iter = otherList.iterator();
        
        while(iter.hasNext())
        {
            SIVARElement bi = (SIVARElement)iter.next();
            this.sivarEleList.add(bi);
        }
    }
    
     public void add(List<SIVARElement> otherList)
    {
        Iterator<SIVARElement> iter = otherList.iterator();
        
        while(iter.hasNext())
        {
            SIVARElement bi = (SIVARElement)iter.next();
            this.sivarEleList.add(bi);
        }
    }
    public SIVARElement getWorkflowNetElements(String businessCode)
    {
        Iterator<SIVARElement> iter = sivarEleList.iterator();
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
    }
    
    
    public SIVARElement firstSIVARElement()
    {
        SIVARElement item = null;
        if(sivarEleList.size()>0){
       item = (SIVARElement)sivarEleList.get(0);
        }
        return item;
    }
    
    
    public integer size()
    {
        return sivarEleList.size();
    }
    
    
    public override  String toString()
    {
        String[] returnValue =new String [0];
        
        SIVARElementIterator iter = this.iterator();
        returnValue.add('<SIVARElementList>');
        while(iter.hasNext())
        {
            SIVARElement item = iter.next();
            returnValue.add(item+'');
            //         returnValue.append(" , ");
        }
        //  returnValue.append("<billingAccountNumber>" + billingAccountNumber);
        //returnValue.append("</billingAccountNumber>");
        
        /**UN COMMENT as needed**/
        returnValue.add('<itemListType>' + itemListType);
        returnValue.add('</itemListType>');
        returnValue.add('</SIVARElementList>');
        String returnValueStr= String.join(returnValue, ', ');
        return returnValueStr;
    }
    
    public List<SIVARElement> getSIVARElementList()
    {
        return sivarEleList;
    }
    
    //supposedly, filtered items will be returned back..
    //This is the method implementation from the FilterableList interface
    public SIVARElementList getSIVARElements()
    {
        return this;
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
if ( (c != null) && (sivarEleList!= null) )
{
Collections.sort(sivarEleList, c);
}
} */
    
    /**
* @return
* @uml.property  name="itemListType"
*/
    public integer getSIVARElementListType()
    {
        return itemListType;
    }
    
    public boolean contains(SIVARElement item)
    {
        //check for implementation
        boolean found = false;
        for(SIVARElement elem : sivarEleList){
            if(item == elem){
                found = true;
                break;
            }
        }
        return  found;
    }
}