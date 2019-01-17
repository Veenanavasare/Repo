/*
Component Name : SI_ChatterFeedCommentTriggerHandler 
Requirement/User Story Number : US269803, US269806, US269809, US308947
Requirement Description:Prevent users from saving records with Blocked Words and Audit Use of Blocked Words and append Disclaimer to Chatter comments by AT&T Employees on Chatter for Communities
Component Author:Accenture IDC
Created Date:4th September 2014 
Version:1.0
Last Modified By: Accenture IDC
*/  
public with sharing class SI_ChatterFeedCommentTriggerHandler extends SITriggerOperations.SITriggerImpl 
{
    //Global variables
    public boolean isExecuted;
    public boolean isCommunityUser;
    public boolean isPartnerUser;
    public string urlType;
    public User usrComUser {get;set;}
 
    //Default cons
    public SI_ChatterFeedCommentTriggerHandler() 
    {
      urlType = URL.getSalesforceBaseUrl().toExternalForm();
      isExecuted = true;
    }
    
    //An Overridden method
    public override boolean onBeforeInsert(SObject[] newObjects) 
    {
        try 
        {
            DisclaimerOnFeedComment(newObjects);
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
            checkBlockedWordsOnFeedComments( newObjects );
        } 
        catch(Exception excep) 
        {
            isExecuted = false;
            throw excep;
        }
        return isExecuted;
    }
    
    //Disclaimer Method
    public void DisclaimerOnFeedComment(SObject[] newObjects)
    {
        usrComUser =[Select Id, UserType from User where ID=:UserInfo.getUserId()];
            
        try{
        if(usrComUser.UserType==SIConstants.User_Type_Customer)
        { 
            isCommunityUser=true; 
        }
        else
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
        List<FeedComment> FeedCommentList=newObjects;
        string s = UtilityConstant.N+ SpecialCharacterConstant.BLANK;
        if(urlType.contains(UtilityConstant.ATTPARTNEREXCHANGE))
        {    
            if(!isCommunityUser)
            {
                for (FeedComment f: FeedCommentList)
                {
                    if(f.CommentBody!= NULL && !f.CommentBody.contains('I am an AT&T employee and the postings on this site are my own and don’t necessarily represent AT&T’s position, strategies or opinions'))
                    {
                        f.CommentBody=f.CommentBody + UtilityConstant.N_N_N + s ;
                    }
                    else if (f.CommentBody== NULL)
                    {
                        f.CommentBody=s;
                    }
               }
            } 
        }
        }catch(Exception e){
                ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }

    }
    
    //Business logic to check whether comment contains any blocked word.  
    public void checkBlockedWordsOnFeedComments(  SObject[] newObjects )
    {
        list<FeedComment> newfeedCommentList = newObjects;
        list<FeedComment> feedCommentList = new list<FeedComment>();
        list<PatternHelper> patterns = new list<PatternHelper>();
        string body = null;
        map<Id, set<String>> blockedWordsmap = new map<Id, set<String>>();
        map<String, Id> blockedWordIds = new map<String, Id>();
        list<FeedComment> createAuditRecords = new list<FeedComment>();
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
        for(FeedComment feedComments : newfeedCommentList)
        {
            if( feedComments.CommentBody!= null )
            {
                feedCommentList.add(feedComments);
            }
        }
        
        if( feedCommentList.size() > 0 )
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
                     blockedWordIds.put(blockedWord.Blocked_Word__c,blockedWord.Id);// Map of blocked words and there Id's
                     patterns.add(new PatternHelper(blockedWord));// creating a wrapper object with pattern.
                }
                
                for( FeedComment fComment : feedCommentList )
                {
                    boolean preventPost = false;
                    String matchedWord = UtilityConstant.REGEX;
                    body = fComment.CommentBody;
                    
                    for(PatternHelper ph : patterns)
                    {
                        Matcher myMatcher = ph.p.matcher(body);
                        
                        //Statement to find the match
                        if(myMatcher.find())
                        {
                            if(ph.blacklistedWord.Prevent_Post__c)
                            {
                                displayError.put(fComment.Id,true); //Map which contains for which feed comments to display error.
                            }
                            if( blockedWordsmap.get(fComment.Id) !=null ){
                                set<String> buffer = blockedWordsmap.get(fComment.Id);
                                buffer.add(ph.blacklistedWord.Blocked_Word__c);
                                blockedWordsmap.put(fComment.Id,buffer); //Map to store multiple blocked words to display list of blocked words in a single error statement.
                            }
                            else{
                                set<String> buffer = new set<String>();
                                buffer.add(ph.blacklistedWord.Blocked_Word__c);
                                blockedWordsmap.put(fComment.Id,buffer); //Map to store multiple blocked words to display list of blocked words in a single error statement.
                            }
                        }
                    }
                }
                for( FeedComment fCommentDisErr : feedCommentList )
                {
                    if( blockedWordsmap.get(fCommentDisErr.Id) != null )
                    {
                        if( displayError.get(fCommentDisErr.Id) !=null && displayError.get(fCommentDisErr.Id))
                        {
                            set<String> buffer = blockedWordsmap.get(fCommentDisErr.Id);
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
                            fCommentDisErr.addError(SIConstants.chatterPost_ErrMsg+bufferToStoreWord+'".');
                        }
                        else{
                            createAuditRecords.add(fCommentDisErr); //list used to store feed comments for which Audit record needs to be created.
                        }
                        
                    }
                }
                
                //Business logic to create Audit records
                for(FeedComment createAudit : createAuditRecords)
                {
                    set<String> blockedWordAudit =  blockedWordsmap.get(createAudit.Id);
                    
                    for(String word : blockedWordAudit)
                    {
                        Blocked_Word_Audit__c bWAudit = new Blocked_Word_Audit__c();
                        bWAudit.Blocked_Word_Record__c = blockedWordIds.get(word);
                        bWAudit.Date_of_Use__c = system.now();
                        bWAudit.Original_Text__c = createAudit.CommentBody;
                        bWAudit.Post_Type__c = SIConstants.Post_Type_ChatterComment;
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