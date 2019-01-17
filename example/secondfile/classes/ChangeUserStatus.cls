public class ChangeUserStatus
{
    @future
    public static void updateUserStatus(Set<Id> accountIds, Boolean flag) 
    {
        list<User> listOfUsersToActivate = new list<User>();
        list<User> listOfUsersToDeactivate = new list<User>();   
        
        if(flag)
        {
            listOfUsersToDeactivate = [ SELECT id, isActive,Name, Active_Previously__c from User WHERE AccountId in :accountIds];
        
            if( listOfUsersToDeactivate.size() > 0 && listOfUsersToDeactivate != null )
            {
                for( User u : listOfUsersToDeactivate )
                {
                    system.debug('@@@@@@'+u.Name+u.isActive);
                    if( u.isActive == true )
                    {
                        u.isActive = false;
                        u.Active_Previously__c = true;
                    }
                }
                update listOfUsersToDeactivate;
            }
        }
        else
        {
            listOfUsersToActivate = [ SELECT id, isActive, Active_Previously__c from User WHERE AccountId in :accountIds];
            
            if( listOfUsersToActivate.size() > 0 && listOfUsersToActivate != null )
            {
                for( User u : listOfUsersToActivate )
                {
                    if( u.Active_Previously__c == True )
                    {
                        u.isActive = true;
                        u.Active_Previously__c = false;
                    }
                }
                update listOfUsersToActivate; 
             }
             system.debug('@@@listOfUsersToActivate'+listOfUsersToActivate);  
        }
    }
}