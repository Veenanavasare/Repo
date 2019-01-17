/************************************************************************************** 
 Apex Class Name     : BirchAccountProvRequestBean
 Version             : 1.0 
 Created Date        : 23 Aug 2015
 Function            : This class handles the request for birch user account provisioning request 
 Modification Log    :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Anand M            8/23/2015              Original Version

*************************************************************************************/
public class BirchAccountProvRequestBean extends ATTServiceInfoBean 
{
	public String UserUniqueId;	
	public String Program;	
	public String Username;	
	public String LanguageCode;	
	public String Title;
	public String FirstName;
	public String Surname;	//sample string 7
	public String UserAddress1;	//sample string 8
	public String UserAddress2;	//sample string 9
	public String UserAddress3;	//sample string 10
	public String UserCity;	//New York
	public String UserZip;	//10036
	public String UserState;	//NY
	public String UserCountry;	//USA
	public String UserReportingRegion;	//sample string 15
	public String UserTel;	//sample string 16
	public String UserFax;	//sample string 17
	public String UserEmail;	//sample string 18
	public String UserMobile;	//sample string 19
	public String AccountUniqueId;	//SFDC-TEST-1
	public String AccountName;	//sample string 21
	public String PartnerType;	//sample string 22
	public String PartnerLevel;	//sample string 23
	public String AccountAddress1;	//sample string 24
	public String AccountAddress2;	//sample string 25
	public String AccountAddress3;	//sample string 26
	public String AccountCity;	//sample string 27
	public String AccountZip;	//sample string 28
	public String AccountState;	//sample string 29
	public String AccountCountry;	//USA
	public String AccountReportingRegion;	//sample string 31
	public String PrimaryContactFirstName;	//sample string 32
	public String PrimaryContactSurname;	//sample string 33
	public String PrimaryContactPosition;	//sample string 34
	public String PrimaryContactEmail;	//sample string 35
	public String AccountTel;	//sample string 36
	public String AccountFax;	//sample string 37
	public String AccountMobile;	//sample string 38
	public String RoleType;	//Admin
	public String convId;
    /**
    public class SecurityHeader {
        //public String convId;
        public String clientId;
        public String authToken;
    }
    **/
    //public String version;
//    public SecurityHeader SecurityHeader;
    
    public static BirchAccountProvRequestBean parse(String json){
		return (BirchAccountProvRequestBean) System.JSON.deserialize(json, BirchAccountProvRequestBean.class);
	}
}