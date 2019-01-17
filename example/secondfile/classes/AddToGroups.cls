public class AddToGroups
{
    @future
    public static void addToPublicGroup(Set<Id> userIds) 
    {
        if( !test.isRunningTest() ) {
            List<User> users=[select id, Username, profileId from User where id in :userIds];
            CollaborationGroup internalGroup = [select id FROM CollaborationGroup where Name = 'All AT&T Partner Exchange'];
            CollaborationGroup communityGroup = [select id FROM CollaborationGroup where Name = 'Community - Get Started!'];
            List<CollaborationGroupMember> internalGroupMembers = new List<CollaborationGroupMember>();
            List<CollaborationGroupMember> communityGroupMembers = new List<CollaborationGroupMember>();
            
            for(User user: users)
            {
                if(user.profileId != label.Partner_UserId)
                {            
                    if(user.profileId != label.Community_User_Id)
                    { 
                        CollaborationGroupMember newMember = new CollaborationGroupMember(CollaborationGroupId=internalGroup.id, MemberId = user.Id);
                        internalGroupMembers.add(newMember);
                    } 
                    else
                    {
                        CollaborationGroupMember newMember = new CollaborationGroupMember(CollaborationGroupId=communityGroup.id, MemberId = user.Id);
                        communityGroupMembers.add(newMember);
                    }
                }   
            }
            if (internalGroupMembers.size() > 0 )
                insert internalGroupMembers;
            if (communityGroupMembers.size() > 0 )    
                insert communityGroupMembers;
        }
    }
    
    /*Name:addSIEBMUserToLibraryViewerGroup
    Description:
    */  
     
    @future  
    public static void addSIEBMUserToLibraryViewerGroup(Set<Id> userIds){ 
        try{    
            Group g=[select Id from Group Where Name='Library Viewers'];
            List<User> users=[select id, UserPermissionsSFContentUser from User where IsActive = True AND Profile.Name like '%SI_EBM%' AND Profile.Name != 'SI_EBM Training API User' AND id in :userIds];
            List<GroupMember> listGroupMemberList =new List<GroupMember>();  
            for(User user: users){
                GroupMember gm = new GroupMember(); 
                gm.GroupId=g.id;
                gm.UserOrGroupId = user.id;
                listGroupMemberList.add(gm);
            }
            if(listGroupMemberList.size()>0){
                insert listGroupMemberList ;
            }
        }
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
        }
    }
}