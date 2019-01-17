public class SITopicHierarchyController 
{
    list <Topic__c> childTopics {get;set;}
    list<Topic__c> grandChildTopics {get;set;}
    public list<Topic__c> peerTopics {get;set;}
    public Topic__c grandParentTopic {get;set;}
    public Topic__c parentTopic {get;set;}
    public boolean haveParent {get;set;}
    public boolean haveGrandParent {get;set;}
    public boolean isChild {get;set;}
    //public boolean isParent {get;set;}
    public boolean isGrandChild {get;set;}
    public map <Id,list <Topic__c>> parentChildMap = new map <Id,list <Topic__c>>();
    public list <WrappedTopic> topicsList {get;set;}
    private final Topic__c topic; 
    public SITopicHierarchyController(ApexPages.StandardController stdController) 
    {
         this.topic= (Topic__c)stdController.getRecord();
         topicsList =new list <WrappedTopic>();
         getChildrenData();
    }

    public void getChildrenData()
    {
       childTopics = new list <Topic__c>();
       grandChildTopics = new list <Topic__c>();
       childTopics = [SELECT Name,Id,Parent_Topic__c FROM Topic__c WHERE Parent_Topic__c= :topic.Id];
       if(!childTopics.isEmpty()&& childTopics != null)
       {
            grandChildTopics = [SELECT Name,Id,Parent_Topic__c FROM Topic__c WHERE Parent_Topic__c IN :childTopics];
       }
       
       if(topic.Parent_Topic__c != null)
       {          
           haveParent =true;
           peerTopics = [SELECT Name,Id,Parent_Topic__c FROM Topic__c tp WHERE tp.Parent_Topic__c = :topic.Parent_Topic__c];          
           parentTopic = [SELECT Name,Id,Parent_Topic__c FROM Topic__c WHERE Id =:topic.Parent_Topic__c];
           try
           {
               grandParentTopic = [SELECT Name,Id,Parent_Topic__c FROM Topic__c WHERE Id = :parentTopic.Parent_Topic__c];
               haveGrandParent = true;
           }
           catch (Exception e)
           {
               haveGrandParent = false;
               system.debug('Exception : '+e);
           }
       }
       else
       {
           haveParent= false;
           haveGrandParent = false;
       }
       if(!grandChildTopics.isEmpty() && grandChildTopics != null)
       {
           isGrandChild =true;
           isChild = true;
       }
       else
       {
           isGrandChild =false;
           if(!childTopics.isEmpty() && childTopics != null)
           {
               isChild = true;
           }
           else
           {
               isChild = false;
           }
       }
       
       if(isGrandChild && isChild )
       {
           for(Topic__c pt : childTopics )
           {
               for(Topic__c ct :grandChildTopics)
               {
                   if(ct.Parent_Topic__c == pt.Id)
                   {
                       list <Topic__c> tempList = new list <Topic__c>();
                       if(parentChildMap.containsKey(pt.Id))
                       {
                           tempList = parentChildMap.get(pt.Id);
                           templist.add(ct);
                           parentChildMap.put(pt.Id,templist);
                       }
                       else
                       {
                           tempList.add(ct);
                           parentChildMap.put(pt.Id,templist);
                       }
                   }
               }
           }
       } 
       
       if(isChild) 
       {
           for(Topic__c tp : childTopics)
           {
               topicsList.add(new WrappedTopic(tp,parentChildMap ));
           }
       }    
    }
    
    public class WrappedTopic
    {
        public Topic__c detail {get; set;}
        public boolean isChildern {get;set;}
        public list<Topic__c> children { get; set; }
        //public map <Id,list <Topic__c>> wrapperParentChildMap {get;set}
        public WrappedTopic( Topic__c theTopic,map <Id,list <Topic__c>> parentChildMap ) 
        {
            this.detail = theTopic;
            this.children = new list<Topic__c>();           
            if(parentChildMap.containsKey(detail.Id))
            {
                 this.children = parentChildMap.get(detail.Id);
                 this.isChildern = true;     
            }
            else
            {
                this.isChildern = false;
            }
        }
    }
}