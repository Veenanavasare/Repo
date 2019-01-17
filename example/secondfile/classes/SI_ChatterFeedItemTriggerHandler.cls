/*
Component Name : SI_ChatterFeedItemTriggerHandler 
Requirement/User Story Number : US269803, US269806, US269809, US308947 
Requirement Description : Prevent users from saving records with Blocked Words and Audit Use of Blocked Words and append Disclaimer to Chatter posts by AT&T Employees on Chatter for Communities
Component Author : Accenture IDC
Created Date : 4th September 2014 
Version : 1.0
Last Modified By : Accenture IDC
*/  
public with sharing class SI_ChatterFeedItemTriggerHandler extends SITriggerOperations.SITriggerImpl 
{
    //Global variables  
    public boolean isExecuted ;
    public boolean isCommunityUser ;
    public boolean isPartnerUser ;
    public User usrComUser {get;set;}
    public string urlType;
 
    //Default cons
    public SI_ChatterFeedItemTriggerHandler() 
    {
        urlType = URL.getSalesforceBaseUrl().toExternalForm();
        isExecuted = true;
    }
    
    //An Overridden method
    public override boolean onBeforeInsert(SObject[] newObjects) 
    {
        try
        {
            DisclaimerOnFeedItem(newObjects);
            //checkBlockedWordsOnFeedItems( newObjects );
        } 
        catch(Exception excep) 
        {
            isExecuted = false;
            throw excep;
        }
        return isExecuted;
    }
    
    //An Overridden method
     public override boolean onAfterInsert(SObject[] newObjects) 
     {
        try 
        {
            checkBlockedWordsOnFeedItems( newObjects );
        } 
        catch(Exception excep) 
        {
            isExecuted = false;
            throw excep;
        }
        return isExecuted;
    }
    
    // Disclaimer Method
    public void DisclaimerOnFeedItem(SObject[] newObjects)
    {
        usrComUser =[Select Id, UserType from User where ID=:UserInfo.getUserId()]; 
        try{
        if(usrComUser.UserType==SIConstants.User_Type_Customer){ 
            isCommunityUser=true; 
        }else{
            isCommunityUser=false;
        } 
        if(usrComUser.UserType==SIConstants.User_Type_Partner)
        { 
            isPartnerUser=true; 
        }
        else
        {
            isPartnerUser=false;
        }
        List<FeedItem> FeedItemList=newObjects;
        string s = UtilityConstant.N+SpecialCharacterConstant.BLANK;
        if(urlType.contains(UtilityConstant.ATTPARTNEREXCHANGE))
        {
            if(!(isCommunityUser || isPartnerUser))
            {
                for (FeedItem f: FeedItemList)
                { 
                    if(f.Body!= NULL && !f.Body.contains('I am an AT&T employee and the postings on this site are my own and don’t necessarily represent AT&T’s position, strategies or opinions'))
                    {   
                        f.Body=f.Body + UtilityConstant.N_N_N + s;
                    }
                    else if (f.Body== NULL)
                    {
                        f.Body=s;
                    }
                }
            } 
        }
    
    }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
    }
    }

    
    //Business logic to check whether feed item contains any blocked word.  
    public void checkBlockedWordsOnFeedItems(  SObject[] newObjects )
    {
        list<FeedItem> newfeedItemList = newObjects;
        list<FeedItem> feedItemList = new list<FeedItem>();
        list<PatternHelper> patterns = new list<PatternHelper>();
        string body = null;
        map<Id, set<String>> blockedWordsmap = new map<Id, set<String>>();
        map<String, Id> blockedWordIds = new map<String, Id>();
        list<FeedItem> createAuditRecords = new list<FeedItem>();
        list<Blocked_Word_Audit__c> insertAudidRec = new list<Blocked_Word_Audit__c>();
        map<Id, Boolean> displayError = new map<Id, Boolean>();
        Boolean isCommunityUser = false;
        Boolean isPartnerUser = false;
        list<String> stringOfAudit = new list<String>();

        //Busniess logic to identify community user or not.        
        usrComUser =[Select Id, ContactId,AccountId,UserType from User where ID=:UserInfo.getUserId()];
    try{
        if(usrComUser.UserType==SIConstants.User_Type_Customer)
        { 
            isCommunityUser=true;  
        }else
        {
            isCommunityUser=false;
        }
        if(usrComUser.UserType==SIConstants.User_Type_Partner)
        { 
            isPartnerUser=true; 
        }
        else
        {
            isPartnerUser=false;
        }
        
        //Filter used to fire trigger only for valid scenarios
        for(FeedItem feedItems : newfeedItemList)
        {
            if( feedItems.body != null )
            {
                feedItemList.add(feedItems);
            }
        }
        
        if( feedItemList.size() > 0 )
        {
         //fetch the blacklisted words which are active.
        List<Blocked_Word__c> bwWords = [select Attempted_Uses__c, RegexValue__c, Blocked_Word__c,
                                            Description__c, Match_Whole_Word__c,
                                            Prevent_Post__c,Status__c
                                         from Blocked_Word__c where Status__c = 'Active'];
            if( bwWords.size() > 0 )
            {
                for( Blocked_Word__c blockedWord : bwWords )
                {
                     blockedWordIds.put(blockedWord.Blocked_Word__c,blockedWord.Id);// Map of blocked words and their Id's
                     patterns.add(new PatternHelper(blockedWord));// creating a wrapper object with pattern.
                }
                
                for( FeedItem fItem : feedItemList )
                {
                    boolean preventPost = false;
                    String matchedWord = UtilityConstant.REGEX;
                    body = fItem.Body;
                    
                    for(PatternHelper ph : patterns)
                    {
                        Matcher myMatcher = ph.p.matcher(body);
                        
                        //Statement to find the match
                        if(myMatcher.find())
                        {
                            if(ph.blacklistedWord.Prevent_Post__c)
                            {
                                displayError.put(fItem.Id,true); //Map which contains for which feed items to display error.
                            }
                            if( blockedWordsmap.get(fItem.Id) !=null ){
                                set<String> buffer = blockedWordsmap.get(fItem.Id);
                                buffer.add(ph.blacklistedWord.Blocked_Word__c);
                                blockedWordsmap.put(fItem.Id,buffer); //Map to store multiple blocked words to display list of blocked words in a single error statement.
                            }
                            else{
                                set<String> buffer = new set<String>();
                                buffer.add(ph.blacklistedWord.Blocked_Word__c);
                                blockedWordsmap.put(fItem.Id,buffer); //Map to store multiple blocked words to display list of blocked words in a single error statement.
                            }
                        }
                    }
                }
                for( FeedItem fItemDisErr : feedItemList )
                {
                    if( blockedWordsmap.get(fItemDisErr.Id) != null )
                    {
                        if( displayError.get(fItemDisErr.Id) !=null && displayError.get(fItemDisErr.Id))
                        {
                            set<String> buffer = blockedWordsmap.get(fItemDisErr.Id);
                            String bufferToStoreWord;
                            integer loopCounter =1;
                            for(String blockedwordString : buffer){
                                if( loopCounter == 1 ) {
                                    bufferToStoreWord = blockedwordString;
                                    loopCounter++;
                                }else {
                                    bufferToStoreWord = bufferToStoreWord + SpecialCharacterConstant.COMMA_SPACE+blockedwordString;
                                    loopCounter++;
                                }
                            }
                            fItemDisErr.addError(SIConstants.chatterPost_ErrMsg+bufferToStoreWord+'".');
                        }
                        else{
                            createAuditRecords.add(fItemDisErr); //list used to store feed items object for which Audit record needs to be created.
                        }
                        
                    }
                }
                //Business logic to create Audit records.
                for(FeedItem createAudit : createAuditRecords)
                {
                    set<String> blockedWordAudit =  blockedWordsmap.get(createAudit.Id);
                    
                    for(String word : blockedWordAudit)
                    {
                        Blocked_Word_Audit__c bWAudit = new Blocked_Word_Audit__c();
                        bWAudit.Blocked_Word_Record__c = blockedWordIds.get(word);
                        bWAudit.Date_of_Use__c = system.now();
                        bWAudit.Original_Text__c = createAudit.Body;
                        bWAudit.Post_Type__c = SIConstants.Post_Type_ChatterPost;
                        bWAudit.User_Name__c = userinfo.getUserId();
                        if(isCommunityUser || isPartnerUser )
                        {
                            bWAudit.User_Account__c =  usrComUser.AccountId;
                        }
                        
                        if( URL.getSalesforceBaseUrl().toExternalForm().contains('attpartnerexchange'))
                        {
                            if(isCommunityUser){
                                bWAudit.Posting__c = URL.getSalesforceBaseUrl().toExternalForm() + '/Connect/'+createAudit.Id;
                            }
                            else if(isPartnerUser){
                                bWAudit.Posting__c = URL.getSalesforceBaseUrl().toExternalForm() + '/'+createAudit.Id;
                            }
                        }
                        else
                        {
                            bWAudit.Posting__c = URL.getSalesforceBaseUrl().toExternalForm() + '/'+createAudit.Id;
                        }
                        insertAudidRec.add(bWAudit);
                       
                    }
                }
                
                if( insertAudidRec.size() > 0 )
                {
                    insert insertAudidRec;
                }
                
            } 
        }
    }
catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
}
}
}