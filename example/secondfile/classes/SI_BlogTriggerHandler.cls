/* 
 Name: SITriggerOperations.SITriggerImpl
 Type: Class 
 
 Description: 
 */ 
public with sharing class SI_BlogTriggerHandler extends SITriggerOperations.SITriggerImpl{
    
// Override Method after upate
public override boolean onAfterUpdate(SObject[] oldObjects, SObject[] updatedObjects, Map<Id, SObject>  newObjectsMap)
    {
        try
        {
            CheckNFeaturedBlogs(updatedObjects);
        }
        catch (exception e)
        {
        }
        return true;
    } 
    
// override method after insert
    public override boolean onAfterInsert (SObject[] newObjects)
    {
        try
        {
            CheckNFeaturedBlogs(newObjects);
        }
        catch (exception e)
        {
        }
        return true;
    }  
    
// Method for CheckNFeaturedBlogs
    public void CheckNFeaturedBlogs(SObject[] updatedObjects )
    {
        Integer total_size=0;
        List<Blog__c> BlogList=updatedObjects;
    
        total_size =[select count() from Blog__c where Featured_Blog__c=true];
        
        try{
        if(total_size>4){
            for(Blog__c B:BlogList){
              B.Featured_Blog__c.adderror('Only four Blogs can be marked as Featured at any given time');
              }
        }
        }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }

      /*  for(Blog__c B:BlogList){
        
        
            if(B.Featured_Blog__c){
                if(B.Featured_image__c==null)
                    B.Featured_image__c.adderror('Please upload an Blog Image to mark the Blog as Featured');
                else if(!B.Featured_image__c.startsWith('<img alt') ||!B.Featured_image__c.endsWith('</img>'))
                  B.Featured_image__c.adderror('Please upload an Blog image to mark the Blog as Featured(Only image should be uploaded)');
            }
            if(B.Blog_Status__c==SampleUtilityConstant.ACTIVE){
                if(B.Banner_Image__c==null)
                B.Banner_Image__c.adderror('Please upload an Banner Image to mark the Blog as Active');
             else if (!B.Banner_Image__c.startsWith('<img alt') || !B.Banner_Image__c.endsWith('</img>') )
                B.Banner_Image__c.adderror('Please upload an Banner Image to mark the Blog as Active(Only image should be uploaded)');
            }
        }*/
    }