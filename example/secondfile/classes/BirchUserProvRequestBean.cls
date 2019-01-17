/************************************************************************************** 
 Apex Class Name     : BirchUserProvRequestBean
 Version             : 1.0 
 Created Date        : 23 Aug 2015
 Function            : This class handles the request for birch user provisioning request 
 Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Anand M            8/23/2015              Original Version

*************************************************************************************/
public class BirchUserProvRequestBean extends ATTServiceInfoBean 
{
    
	public String UniqueId;	//sample string 1
	public String Program;	//ATTMDF
	public String Username;	//sample string 3
	public String LanguageCode;	//sample string 4
	public String Title;	//sample string 5
	public String FirstName;	//sample string 6
	public String Surname;	//sample string 7
	public String Address1;	//sample string 8
	public String Address2;	//sample string 9
	public String Address3;	//sample string 10
	public String City;	//sample string 11
	public String Zip;	//sample string 12
	public String State;	//sample string 13
	public String Country;	//USA
	public String ReportingRegion;	//sample string 15
	public String Tel;	//sample string 16
	public String Fax;	//sample string 17
	public String Email;	//sample string 18
	public String Mobile;	//sample string 19
	public cls_UserAccountAccess[] UserAccountAccess;
    
	public class cls_UserAccountAccess {
		public String AccountUniqueId;	//sample string 1
		public String RoleType;	//User
		public boolean DefaultAccount;
	}
	public String convId;
    public String action; //A for Create and U for Update
    /**
    public class SecurityHeader {
       // public String convId;
        public String clientId;
        public String authToken;
    }
    
    public String version;
    public SecurityHeader SecurityHeader;
    **/
    public static BirchUserProvRequestBean parse(String json){
        return (BirchUserProvRequestBean) System.JSON.deserialize(json, BirchUserProvRequestBean.class);
    }
}