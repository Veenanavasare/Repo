/* 
 Class Name: PermissionSets
 Description: PermissionSets
 */ 
public class PermissionSets
{      
    @future    
    public static void addUserToPermissionSets(Set<Id> userIds)
    {
        
            //Select list of partner users present in the set of id's passed from SIUserTriggerHandler on afterinsert and after update of a User Record
            List<User> partnerUserList = [select id, isActive, Username, Create_Modify_Profile__c, Begin_Quote__c, Approve_Contracts__c, Provider_Directory__c, User_License_Type__c from User where id in : userIds];
            
            // Lists of users to which the appropriate permissions are to be assigned    
            list<PermissionSetAssignment> createModifyProfileAccessList= new list<PermissionSetAssignment>();
            list<PermissionSetAssignment> beginQuoteAccessList= new list<PermissionSetAssignment>();
            list<PermissionSetAssignment> approveContractsAccessList= new list<PermissionSetAssignment>();
            list<PermissionSetAssignment> providerDirectoryAccessList= new list<PermissionSetAssignment>();
            
            // Lists of users to which the appropriate permissions are to be removed
            list<PermissionSetAssignment> createModifyProfileDeleteList= new list<PermissionSetAssignment>();
            list<PermissionSetAssignment> beginQuoteDeleteList= new list<PermissionSetAssignment>();
            list<PermissionSetAssignment> approveContractsDeleteList= new list<PermissionSetAssignment>();
            list<PermissionSetAssignment> providerDirectoryDeleteList= new list<PermissionSetAssignment>();
            
            //Sets of strings which have the id's of users already assigned the permission set
            Set<String> usersWithAccessToCreateModifyProfile = new Set<String>();
            Set<String> usersWithAccessToBeginQuote = new Set<String>();
            Set<String> usersWithAccessToApproveContracts = new Set<String>();
            Set<String> usersWithAccessToProviderDirectory = new Set<String>();
            
            //Ids of the permission sets    
            Id createModifyProfilePSId;
            Id beginQuotePSId;
            Id approveQuotePSId;
            Id providerDirectoryPSId;
       
            //Add the users to the appropriate sets already present in the appropriate permission sets     
            
            for ( PermissionSet ps : [ SELECT Id FROM PermissionSet WHERE Name =: UtilityConstant.CREATEMODIFYPROFILE] ) 
            {
                createModifyProfilePSId = ps.Id;      //assign the premission set Id
                for (PermissionSetAssignment psa : [ SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId =: ps.Id] )  //query for users that are already assigned
                { 
                    usersWithAccessToCreateModifyProfile.add(psa.AssigneeId); 
                }
            }
            for ( PermissionSet ps : [ SELECT Id FROM PermissionSet WHERE Name =: UtilityConstant.BEGINQPERMSET] ) 
            {
                beginQuotePSId = ps.Id;              //assign the premission set Id
                for (PermissionSetAssignment psa : [ SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId =: ps.Id] )  //query for users that are already assigned
                { 
                    usersWithAccessToBeginQuote.add(psa.AssigneeId); 
                }
            }
            for ( PermissionSet ps : [ SELECT Id FROM PermissionSet WHERE Name =: UtilityConstant.SPAPRPERMSET] ) 
            {
                approveQuotePSId = ps.Id;           //assign the premission set Id
                for (PermissionSetAssignment psa : [ SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId =: ps.Id] )  //query for users that are already assigned
                { 
                    usersWithAccessToApproveContracts.add(psa.AssigneeId); 
                }
            }
            for ( PermissionSet ps : [ SELECT Id FROM PermissionSet WHERE Name =:UtilityConstant.PROVIDERDIRECTORY] ) 
            {
                providerDirectoryPSId = ps.Id;      //assign the premission set Id
                for (PermissionSetAssignment psa : [ SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId =: ps.Id] )  //query for users that are already assigned
                { 
                    usersWithAccessToProviderDirectory.add(psa.AssigneeId); 
                }
            }         
              
         
            
            // Assigning user or removing user from Permission Set
            if( partnerUserList.size() > 0 && partnerUserList != null)
            {
                for( User u : partnerUserList )
                {
                    //Adding user to Create/Modify Profile permission set if Create/Modify Permission is True
                    if (!usersWithAccessToCreateModifyProfile.contains(u.Id))   
                    { 
                       
                        if( u.Create_Modify_Profile__c == True && u.isActive == True )
                        {
                            
                            PermissionSetAssignment newPSA = new PermissionSetAssignment(); 
                            newPSA.PermissionSetId = createModifyProfilePSId;   //set the permission set Id
                            newPSA.AssigneeId = u.Id;                           //set the User Id
                            createModifyProfileAccessList.add(newPSA);          //add the record to our list
                            
                        }
                   }
                   //Removing user from Create/Modify Profile permission set if Create/Modify Permission is False
                   else 
                   {
                        for ( PermissionSet ps : [ SELECT Id FROM PermissionSet WHERE Name =: UtilityConstant.CREATEMODIFYPROFILE] ) 
                        {
                            for ( PermissionSetAssignment psa : [ SELECT id FROM PermissionSetAssignment WHERE PermissionSetId =: ps.Id AND AssigneeId =: u.Id] )
                            {
                                if( u.Create_Modify_Profile__c == False )
                                {
                                     createModifyProfileDeleteList.add(psa);
                             
                                }    
                            }
                        }
                    } 
                    
                    //Adding user to Begin Quote permission set if Begin Quote Permission is True
                    if (!usersWithAccessToBeginQuote.contains(u.Id))   
                    { 
                        
                        if( u.Begin_Quote__c == True && u.isActive == True )
                        {
                            
                            PermissionSetAssignment newPSA = new PermissionSetAssignment(); 
                            newPSA.PermissionSetId = beginQuotePSId;            //set the permission set Id
                            newPSA.AssigneeId = u.Id;                           //set the User Id
                            beginQuoteAccessList.add(newPSA);                   //add the record to our list
                         
                        }
                   }
                   //Removing user from Begin Quote permission set if Begin Quote Permission is False
                   else 
                   {
                        for ( PermissionSet ps : [ SELECT Id FROM PermissionSet WHERE Name = :UtilityConstant.BEGINQPERMSET] ) 
                        {
                            for ( PermissionSetAssignment psa : [ SELECT id FROM PermissionSetAssignment WHERE PermissionSetId =: ps.Id AND AssigneeId =: u.Id] )
                            {
                                if( u.Begin_Quote__c == False )
                                {
                                     beginQuoteDeleteList.add(psa);
                                }    
                            }
                        }
                    } 
                    
                    //Adding user to SP Approver permission set if Approve Contracts Permission is True
                    if (!usersWithAccessToApproveContracts.contains(u.Id))   
                    { 
                        if( u.Approve_Contracts__c == True && u.isActive == True )
                        {
                            PermissionSetAssignment newPSA = new PermissionSetAssignment(); 
                            newPSA.PermissionSetId = approveQuotePSId;          //set the permission set Id
                            newPSA.AssigneeId = u.Id;                           //set the User Id
                            approveContractsAccessList.add(newPSA);             //add the record to our list
                            
                        }
                   }
                   //Removing user from SP Approver permission set if Approve Contracts Permission is False
                   else 
                   {
                        for ( PermissionSet ps : [ SELECT Id FROM PermissionSet WHERE Name =: UtilityConstant.SPAPRPERMSET] ) 
                        {
                            for ( PermissionSetAssignment psa : [ SELECT id FROM PermissionSetAssignment WHERE PermissionSetId =: ps.Id AND AssigneeId =: u.Id] )
                            {
                                if( u.Approve_Contracts__c == False )
                                {
                                     approveContractsDeleteList.add(psa);
                                    
                                }    
                            }
                        }
                    } 
                    
                    //Adding user to Provider Directory permission set if Provider Directory Permission is True
                    if (!usersWithAccessToProviderDirectory.contains(u.Id))   
                    { 
                        
                        if( u.Provider_Directory__c == True && u.isActive == True )
                        {
                            
                            PermissionSetAssignment newPSA = new PermissionSetAssignment(); 
                            newPSA.PermissionSetId = providerDirectoryPSId;     //set the permission set Id
                            newPSA.AssigneeId = u.Id;                           //set the User Id
                            providerDirectoryAccessList.add(newPSA);            //add the record to our list
                            
                        }
                   }
                   //Removing user from Provider Directory permission set if Provider Directory Permission is False
                   else 
                   {
                        for ( PermissionSet ps : [ SELECT Id FROM PermissionSet WHERE Name =:UtilityConstant.PROVIDERDIRECTORY] ) 
                        {
                            for ( PermissionSetAssignment psa : [ SELECT id FROM PermissionSetAssignment WHERE PermissionSetId =: ps.Id AND AssigneeId =: u.Id] )
                            {
                                if( u.Provider_Directory__c == False )
                                {
                                     providerDirectoryDeleteList.add(psa);
                                     
                                }    
                            }
                        }
                    }   
                }
            }

                        
            //Inserting the Permission Set Assignment records for the users that meet the criteria
             if(!Test.isRunningTest()){
            if ( !createModifyProfileAccessList.isEmpty() && createModifyProfileAccessList!= null )   
            { 
                insert createModifyProfileAccessList; 
            }
            if ( !beginQuoteAccessList.isEmpty() && beginQuoteAccessList!= null )   
            { 
                insert beginQuoteAccessList; 
            }
            if ( !approveContractsAccessList.isEmpty() && approveContractsAccessList!= null )   
            { 
                insert approveContractsAccessList; 
            }
            if ( !providerDirectoryAccessList.isEmpty() && providerDirectoryAccessList!= null )   
            { 
                insert providerDirectoryAccessList; 
            }
            }
            
            //Deleting the Permission Set Assignment records for the users that do not meet criteria
            delete createModifyProfileDeleteList;
            delete beginQuoteDeleteList;
            delete approveContractsDeleteList;
            delete providerDirectoryDeleteList;
         }
         
   
}