/************************************************************************************** 
 Apex Class Name     : ESignContractIntegrationInterface
 Version             : 1.0 
 Created Date        : 5 January 2017
 Function            : Interface class for the Esign Request Calls
*************************************************************************************/
                    
public interface ESignContractIntegrationInterface{

    EsignContractInfoBean handleESignRequest(EsignContractInfoBean contractInfobean);
}