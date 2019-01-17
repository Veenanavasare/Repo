public class ProfilePermission{    
    public ProfilePermission thePDFControllerInstance { get { return this; } }
    public List<User> currentUser {get;set;}
    public Integer hasPremission {get;set;}
    public String doc { get; set; }
    public Map<String,String> DocumentMap{get; set;}
    public list<Folder> folderId; 
    public Id acctId;
    public boolean isStopBirch {get;set;}  
    
    public ProfilePermission(){
    currentUser = [SELECT Manage_MDF__c,MDF_Read_Only__c,contact.AccountId,Stop_Birch__c FROM User WHERE Id =:UserInfo.getUserId() and (Manage_MDF__c=:true or MDF_Read_Only__c=:true)];
    hasPremission = currentUser.size();
    
     if(currentUser!=null && currentUser.size()>0)
    {
        isStopBirch=currentUser[0].Stop_Birch__c;
    }
    else
    {
           isStopBirch=false;
    }
    // code added by developer
    
    if(currentUser.size()!=0){   // added to fix error by Eliza.
        if(currentUser[0].contact.AccountId !=NULL){
        acctId = currentUser[0].contact.AccountId;
        //getManageMyFundsPerm();
        }
    }
    // 
     try {
            folderId = new list<Folder>();
            String pageUrl = URL.getSalesforceBaseUrl().getHost();
            String folderName = Apexpages.currentPage().getUrl().replace('/apex/','');

            if (folderName.toLowerCase().contains('?')) {
                folderName = folderName.replace('?video=1', '').trim();
            }
			
         	
            if(!String.isempty(folderName)){
            folderId = [select id from Folder where Name=:folderName Limit 1];
            }
            DocumentMap = new Map<String,String>();
            //Changes by khalid CRC 11/29           
            if(folderId!=null && folderId.size()>0){
                for(Document doc : [select id, name, DeveloperName from Document where Document.FolderId =: folderId[0].id]){
                    string DocURL = 'https://'+pageUrl+'/servlet/servlet.FileDownload?file='+doc.Id;
                    if(DocumentMap.containsKey(doc.DeveloperName)==false){
                        DocumentMap.put(doc.DeveloperName,DocURL);
                    }
                }
            }
       }
            catch (Exception e) {
            String exceptionString = ATTException.constructExceptionMessageString(e);
            System.debug('Exception ---- ' + e);
            ATTException.createException(System.Label.paramMissing, e.getTypeName(), exceptionString);                        
        }        
    }
    public void setCurrentUser()
    {
        
        try{
            User cu=[select id FROM User WHERE Id =:UserInfo.getUserId()].get(0);
             Global_Variable__c gv=[SELECT id,Value__C FROM Global_Variable__c WHERE name = 'CurrentUserIdTC' limit 1 FOR UPDATE];
             gv.Value__C=cu.id;
             update gv;
        }
        catch(Exception e)
        {
        
        }               
    }
}