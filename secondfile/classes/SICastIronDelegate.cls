//A delegate class which acts as a mediator between the SFDC and CastIron(API)
public class SICastIronDelegate {
    public static SICastIronDelegate castIronDelegate = null;
    
    private SICastIronDelegate() {}
    
    //Method to get the current instance of the class - Singleton Pattern
    public static SICastIronDelegate getInstance() {
        if(null == castIronDelegate) {
            castIronDelegate = new SICastIronDelegate();
        }
        return castIronDelegate;
    }
    
    //A method which calls the Lead Search Service
    public static List<SICastIronFactory.LeadSearchDecorator> getLeadResults(Lead leadObj) {
        List<SICastIronFactory.LeadSearchDecorator>  leadSearchList = 
            new List<SICastIronFactory.LeadSearchDecorator> ();
        SICastIronFactory.LeadSearchDecorator leadSearDocObj = null;

        try {
            
            //Call to the CastIron
            if(null != leadObj) {
                wwwApprouterComConnectorsWsdl.SFDC_CCI_GetCustomerPort  routerConnector 
                    = new wwwApprouterComConnectorsWsdl.SFDC_CCI_GetCustomerPort();
				edbAttComDppcoCustomerqueryV2.CustomerReadResponse_element leadCustomerResponse;                    
                if(null != routerConnector) {
					leadCustomerResponse = routerConnector.SFDC_CCI_GetCustomer(
	                        String.valueOf(leadObj.Company_Legal_Name__c),
	                        String.valueOf(leadObj.Duns__c),
	                        '',
	                        '',
	                        '',
	                        '',
	                        '',
	                        String.valueOf(leadObj.Street),
	                        '',
	                        String.valueOf(leadObj.City),
	                        String.valueOf(leadObj.State).toUpperCase(),
	                        String.valueOf(leadObj.PostalCode),
	                        ''
	                );
                }
                if(null != leadCustomerResponse && null != leadCustomerResponse.Customer 
                	&& !leadCustomerResponse.Customer.isEmpty()) {
	                for(edbAttComDppcoCommonV2.CustomerDataType castIronleadObj : leadCustomerResponse.Customer) {
	                    leadSearDocObj = new SICastIronFactory.LeadSearchDecorator(
	                        leadSearchList.size() + 1,
	                        castIronleadObj.CustomerName, 
	                        castIronleadObj.Duns, 
	                        castIronleadObj.EcrmAccountRowId, 
	                        castIronleadObj.Address1, 
	                        castIronleadObj.City, 
	                        castIronleadObj.State, 
	                        castIronleadObj.Postal
	                    );
	                    leadSearchList.add(leadSearDocObj); 
	                }
                } 
            } else {            
                //for testing purpose
                for(Integer itemCount = 0; itemCount <11; itemCount++) {
                    leadSearDocObj = new SICastIronFactory.LeadSearchDecorator(
                        leadSearchList.size() + 1,
                        'Customer Name:'+itemCount, 
                        String.valueOf(itemCount), 
                        'Rome Id'+itemCount, //rome not getting from response
                        'Address:'+itemCount, 
                        'City:'+itemCount, 
                        'State/Province:'+itemCount, 
                        String.valueOf(itemCount*2+1)
                    );
                    leadSearchList.add(leadSearDocObj);                 
                }
            }
        } catch(Exception excep) {
            System.debug('SICastIronDelegate.getLeadResults() Exception Caught :'
                +excep.getMessage()+' @Line#'+excep.getLineNumber());
            throw excep;
        }
        return leadSearchList;
    } 
    
    //Call to the CCI System inorder to fetch the upate status(boolan)
    public static String doFetchSPAccountTicket(String ticketSfdcId) {
        String castIronErrorMsg = '';
        
        soapSforceCom200509Outbound.SP_Account_Ticket_xcNotification[] acctNotificationArr = 
            new soapSforceCom200509Outbound.SP_Account_Ticket_xcNotification[1];
        soapSforceCom200509Outbound.SP_Account_Ticket_xcNotification notifcationObjReq = null;
        soapSforceCom200509Outbound.notificationsResponse_element notificationResObj = null;

            
        try {
            if(null != ticketSfdcId && ticketSfdcId.length() > 0) {
                notifcationObjReq = new soapSforceCom200509Outbound.SP_Account_Ticket_xcNotification();
                notifcationObjReq.Id = ticketSfdcId;
                acctNotificationArr[0] = notifcationObjReq;
                  
                notificationResObj = new wwwApprouterComConnectorsWsdlTicket.Provide_ServicePort().
                    Provide_Service(acctNotificationArr);
                
                if(null != notificationResObj) {
                    if(!notificationResObj.ack) {
                        castIronErrorMsg = notificationResObj.message;
                    }
                }
            }
        } catch(Exception excep) {
            System.debug('SICastIronDelegate.doFetchSPAccountTicket() Exception Caught :'
                +excep.getMessage()+' @Line#'+excep.getLineNumber());
        }
        return castIronErrorMsg;
    }
}