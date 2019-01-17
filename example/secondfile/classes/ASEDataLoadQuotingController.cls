public class ASEDataLoadQuotingController {

    public String fileName {get;set;}
    public Transient Blob fileBody {get;set;}
        
    public ASEDataLoadQuotingController(apexpages.standardcontroller stdCon){
        fileBody = null;
        fileName = '';
    }
    public pageReference Attach(){
        if(fileName == null || fileName == ''){
            ApexPages.Message errorMsg1 = new ApexPages.Message(ApexPages.Severity.INFO, 'Please select a File to Upload');
            ApexPages.addMessage(errorMsg1);
            return null;    
        }
        if(!fileName.contains('.csv')){
            ApexPages.Message errorMsg1 = new ApexPages.Message(ApexPages.Severity.INFO, 'Please select a file with .csv format');
            ApexPages.addMessage(errorMsg1);
            return null;    
        }
        if(fileName.length()>54){
            ApexPages.Message errorMsg1 = new ApexPages.Message(ApexPages.Severity.INFO, 'File name should not be more than 50 characters.');
            ApexPages.addMessage(errorMsg1);
            return null;    
        } else{
            ASR_Data_Load__c asrDL = new ASR_Data_Load__c();
            asrDL.file_name__c = fileName;
            asrDL.Upload_Date_Time__c = system.now();
            asrDL.Uploaded_By__c = userInfo.getName();
            asrDL.Upload_Status__c = 'Pending';
            try{
                insert asrDL;
            } Catch(Exception Ex){
                ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.INFO, Ex.getMessage());
                ApexPages.addMessage(errorMsg);
                return null;
            }
            if(fileBody !=null && fileName !=null){
                Attachment attach = new Attachment();
                attach.Body = fileBody;
                attach.Name = fileName;
                attach.ParentId = asrDL.id;
                try{
                    insert attach;    
                }catch(Exception Ex){
                    ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.INFO, Ex.getMessage());
                    ApexPages.addMessage(errorMsg);
                    return null;
                }
           }
           Pagereference sucess  = new Pagereference('/'+asrDL.id);
           sucess.setredirect(true);
           return sucess;
        }
    }
    public pageReference Cancel(){
       Pagereference Upcancel  = new Pagereference('/' + System.label.ASRDataLoadQuotingNavigation);
       Upcancel.setredirect(true);
       return Upcancel;
    }
}