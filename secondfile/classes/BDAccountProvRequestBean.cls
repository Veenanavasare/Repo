/************************************************************************************** 
 Apex Class Name     : BDAccountProvRequestBean
 Version             : 1.0 
 Created Date        : 13 Oct 2015
 Function            : This class handles the request for BD user account provisioning request 
*************************************************************************************/
public class BDAccountProvRequestBean extends ATTServiceInfoBean 
{
    public String name {get;set;} 
    public List<String> offers {get;set;} 
    public String strata {get;set;} 
    public List<String> applications {get;set;} 
    //public String convId;
    
       
    
    public static BDAccountProvRequestBean parse(String json){
        return (BDAccountProvRequestBean) System.JSON.deserialize(json, BDAccountProvRequestBean.class);
    }
}