public abstract class ExecutionModel implements FilterableList
{


    public   Model sivarExecutor;
    public boolean shouldFlip=false;
  
   public ExecutionModel(Model listFilter)
   {
      this.sivarExecutor = listFilter;
   }
   
    public ExecutionModel(SIVARElement element1, SIVARElement element2 )
    {
        
        
    }
    
    public ExecutionModel(SIVARElement element1, SIVARElement element2, SIVARElement element3 )
    {
        
        
    }

   public void flip(boolean val)
   {
     shouldFlip = val;
   }
   protected FilterableList getListFilter()
   {
      return (FilterableList) sivarExecutor;
   }
   public   SIVARElementList getSIVARElements()
   {
       SIVARElementIterator iter = getListFilter().iterator();
       SIVARElementList newList = null;
       if (iter!=null)
       {    
           while(iter.hasNext())
           {    
               SIVARElement item = iter.next(); 
               if (newList==null)
                   newList = new  SIVARElementList(); 
               if(shouldFlip ^ apply(item))
                  {
                    newList.add(item);
                  }
           }
        if (newList==null)
                newList = new SIVARElementList();
   }    
       return newList;
   }

 public SIVARElementIterator iterator() 
   {
      SIVARElementIterator iter = getListFilter().iterator();
      SIVARElementList newList = null;
      while(iter.hasNext())
      {
          SIVARElement item = iter.next();
         if (newList==null)
            newList = new SIVARElementList();
         if (apply(item))
         {
            newList.add(item);
         }
      }
      if (newList==null)
         newList = new SIVARElementList();
      return newList.iterator();
   }
   protected abstract boolean apply(SIVARElement item);
   
//public abstract void applyModel(SIVARElement item) throws WigtApplicationException;
   

}