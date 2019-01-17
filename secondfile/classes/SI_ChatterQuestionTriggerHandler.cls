/*
Component Name : SI_ChatterQuestionTriggerHandler 
Requirement/User Story Number : US269803, US269806, US269809, US308947 
Requirement Description:Prevent users from saving records with Blocked Words and Audit Use of Blocked Words and append Disclaimer to Questions by AT&T Employees on Chatter for Communities
Component Author:Accenture IDC
Created Date:4th Sepetember 2014 
Version:1.0
*/

public with sharing class SI_ChatterQuestionTriggerHandler extends SITriggerOperations.SITriggerImpl 
{
    //Global variables
    public boolean isExecuted ;
    public boolean isCommunityUser ;
    public boolean isPartnerUser;
    public string urlType;
    public User usrComUser {get;set;}

    //Default cons
    public SI_ChatterQuestionTriggerHandler() 
    {
        urlType = URL.getSalesforceBaseUrl().toExternalForm();
        isExecuted = true;
    }
    
    //An Overridden method
    public override boolean onBeforeInsert(SObject[] newObjects) 
    {
        try 
        {
            DisclaimerOnQuestion(newObjects);
        } 
        catch(Exception excep) 
        {
            System.debug('Exception Caught :'+excep.getMessage());
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
            checkBlockedWordsOnQuestions( newObjects );
        } 
        catch(Exception excep) 
        {
            System.debug('Exception Caught :'+excep.getMessage());
            isExecuted = false;
            throw excep;
        }
        return isExecuted;
    }
    
    //An Overridden method
    public override boolean onAfterUpdate(SObject[] oldObjects,SObject[] newObjects,Map<Id,SObject> newObjectsMap )
    {
        try 
        {
            checkBlockedWordsOnQuestions( newObjects );
        } 
        catch(Exception excep) 
        {
            System.debug('Exception Caught :'+excep.getMessage());
            isExecuted = false;
            throw excep;
        }
        return isExecuted;
    }
    
    public void DisclaimerOnQuestion(SObject[] newObjects)
    {
        usrComUser =[Select Id, UserType from User where ID=:UserInfo.getUserId()]; 
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
        List<Question> QuestionList=newObjects;
        string s = '<br/>' +' ';
        
        if(urlType.contains('attpartnerexchange'))
        {    
            if(!isCommunityUser)
            {
                for (Question Q: QuestionList)
                {
                    system.debug('Q.Body'+Q.Body);
                    if(Q.Body!= NULL && Q.Body!= '' && !Q.Body.EQUALSIGNORECASE('I am an AT&amp;T employee and the postings on this site are my own and don’t necessarily represent AT&amp;T’s position, strategies or opinions'))
                    {
                        Q.Body=Q.Body +  '<br/>' + '<br/>' + '<br/>' + s;
                    }
                    else if (Q.Body == NULL)
                    {
                        Q.Body=s;
                    }
                }
            }
        } 
    }
    
    //Business logic to check whether question contains any blocked word.  
    public void checkBlockedWordsOnQuestions(  SObject[] newObjects )
    {
        list<Question> newQuestionList = newObjects;
        list<Question> questionList = new list<Question>();
        list<PatternHelper> patterns = new list<PatternHelper>();
        string body = null;
        map<Id, set<String>> blockedWordsmap = new map<Id, set<String>>();
        map<String, Id> blockedWordIds = new map<String, Id>();
        list<Question> createAuditRecords = new list<Question>();
        list<Blocked_Word_Audit__c> insertAudidRec = new list<Blocked_Word_Audit__c>();
        map<Id, Boolean> displayError = new map<Id, Boolean>();
        Boolean isCommunityUser = false;
        Boolean isPartnerUser = false;
        list<String> stringOfAudit = new list<String>();

        //Busniess logic to identify community user or not.        
        usrComUser =[Select Id, ContactId,AccountId,UserType from User where ID=:UserInfo.getUserId()];
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
        for(Question questions : newQuestionList)
        {
            if( questions.body != null || questions.Title != null )
            {
                questionList.add(questions);
            }
        }
        
        if( newQuestionList.size() > 0 )
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
                
                for( Question q : questionList )
                {
                    boolean preventPost = false;
                    String matchedWord = 'REGEX';
                    body = q.Body +' '+ q.Title;
                    
                    for(PatternHelper ph : patterns)
                    {
                        Matcher myMatcher = ph.p.matcher(body);
                        
                        //Statement to find the match
                        if(myMatcher.find())
                        {
                            if(ph.blacklistedWord.Prevent_Post__c)
                            {
                                displayError.put(q.Id,true); //Map which contains for which questions to display error.
                            }
                            if( blockedWordsmap.get(q.Id) !=null ){
                                set<String> buffer = blockedWordsmap.get(q.Id);
                                buffer.add(ph.blacklistedWord.Blocked_Word__c);
                                blockedWordsmap.put(q.Id,buffer); //Map to store multiple blocked words to display list of blocked words in a single error statement.
                            }
                            else{
                                set<String> buffer = new set<String>();
                                buffer.add(ph.blacklistedWord.Blocked_Word__c);
                                blockedWordsmap.put(q.Id,buffer); //Map to store multiple blocked words to display list of blocked words in a single error statement.
                            }
                        }
                    }
                }
                for( Question questionDisErr : questionList )
                {
                    if( blockedWordsmap.get(questionDisErr.Id) != null )
                    {
                        if( displayError.get(questionDisErr.Id) !=null && displayError.get(questionDisErr.Id))
                        {
                            set<String> buffer = blockedWordsmap.get(questionDisErr.Id);
                            String bufferToStoreWord;
                            integer loopCounter =1;
                            for(String blockedwordString : buffer){
                                if( loopCounter == 1 ) {
                                    bufferToStoreWord = blockedwordString;
                                    loopCounter++;
                                }else {
                                    bufferToStoreWord = bufferToStoreWord + ', '+blockedwordString;
                                    loopCounter++;
                                }
                            }
                            questionDisErr.addError(SIConstants.chatterPost_ErrMsg+bufferToStoreWord+'".');
                        }
                        else{
                            createAuditRecords.add(questionDisErr); //list used to store questions for which Audit record needs to be created.
                        }
                        
                    }
                }
                //Business logic to create Audit records.
                for(Question createAudit : createAuditRecords)
                {
                    set<String> blockedWordAudit =  blockedWordsmap.get(createAudit.Id);
                    
                    for(String word : blockedWordAudit)
                    {
                        Blocked_Word_Audit__c bWAudit = new Blocked_Word_Audit__c();
                        bWAudit.Blocked_Word_Record__c = blockedWordIds.get(word);
                        bWAudit.Date_of_Use__c = system.now();
                        bWAudit.Original_Text__c = createAudit.Title +'\n'+createAudit.Body;
                        bWAudit.Post_Type__c = SIConstants.Post_Type_Question;
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
}