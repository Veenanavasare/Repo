public with sharing class SIBlockedWordTriggerHandler extends SITriggerOperations.SITriggerImpl {
    
    public boolean isExecuted ;

    //Default cons
    public SIBlockedWordTriggerHandler () {
        isExecuted = true;
    }
    
       public override boolean onBeforeUpdate(SObject[] oldObjects, SObject[] updatedObjects, Map<Id, SObject>  newObjectsMap )  {
        try {
                createRegexForBlockedWord(oldObjects,updatedObjects,true);
        } catch(Exception excep) {
            System.debug('Exception Caught :'+excep.getMessage());
            isExecuted = false;
            throw excep;
        }
        return isExecuted;
    }
    
     public override boolean onBeforeInsert(SObject[] updatedObjects)  {
        try {  
                createRegexForBlockedWord(null,updatedObjects,false);
        } catch(Exception excep) {
            System.debug('Exception Caught :'+excep.getMessage());
            isExecuted = false;
            throw excep;
        }
        return isExecuted;
    }
    
    public override boolean onAfterUpdate(SObject[] oldObjects, SObject[] updatedObjects, Map<Id, SObject>  newObjectsMap )  {
    
    try {
                
        } catch(Exception excep) {
            System.debug('Exception Caught :'+excep.getMessage());
            isExecuted = false;
            throw excep;
        }
        return isExecuted;
    }
    
    public void createRegexForBlockedWord( SObject[] oldObjects, SObject[] updatedObjects, Boolean isupdate )
    {
        if(!test.isrunningtest())
        {
        list<Blocked_Word__c> oldBlockedWordList = oldObjects;
        list<Blocked_Word__c> newBlockedWordList = updatedObjects;
        list<Blocked_Word__c> processBlockedWordList = new list<Blocked_Word__c>();
        
        if( !isupdate )
        {
            for(Blocked_Word__c word:newBlockedWordList ){
                if(word.Blocked_Word__c != null && word.Blocked_Word__c!= '')
                {
                    processBlockedWordList.add(word);
                }   
            }
        }
        else{
            for(Integer i=0 ; i< newBlockedWordList.size(); i++){
                if( (oldBlockedWordList[i].Blocked_Word__c != newBlockedWordList[i].Blocked_Word__c) || ( oldBlockedWordList[i].Match_Whole_Word__c == false && newBlockedWordList[i].Match_Whole_Word__c == true ) || ( oldBlockedWordList[i].Match_Whole_Word__c == true && newBlockedWordList[i].Match_Whole_Word__c == false ) )
                {
                    processBlockedWordList.add(newBlockedWordList[i]);
                }
            }
        }
        
        if( processBlockedWordList.size() > 0 )
        {
            for( Blocked_Word__c blockedWord : processBlockedWordList )
            {
                 String wholeWordBoundary = '';
                 if(blockedWord.Match_Whole_Word__c){
                    wholeWordBoundary = '\\b';
                 }
                 String regex = wholeWordBoundary+'(';
                 List<String> chars = blockedWord.Blocked_Word__c.split('',0);
                
                 //start at 1 to skip initial blank entry
                 for(Integer i = 1; i < chars.size(); i++)
                 {
                    if(chars[i] == ' ') //1.6 add support for multiple words
                         regex += '[ ]';
                    else
                         regex += '['+chars[i].toLowerCase()+'|'+chars[i].toUpperCase()+']';
                 }
                 blockedWord.RegexValue__c = regex + ')'+wholeWordBoundary;
            }
        }
        
        }
    }
    
}