/************************************************************************************** 
 Apex Class Name     : BDUserProvRequestBean
 Version             : 1.0 
 Created Date        : 13 Oct 2015
 Function            : This class handles the request for BD user  provisioning request 
*************************************************************************************/
public class BDUserProvRequestBean extends ATTServiceInfoBean 
{
    public String companyId {get;set;} 
    public String proposedId{get;set;} 
    public String firstName{get;set;} 
    public String lastName{get;set;} 
    public String emailAddress{get;set;} 
    public String zipCode{get;set;} 
    public String userType{get;set;} 
    public List<String> applications{get;set;}
    //public String convId;
    
       
    
    public static BDUserProvRequestBean parse(String json){
        return (BDUserProvRequestBean) System.JSON.deserialize(json, BDUserProvRequestBean.class);
    }
}