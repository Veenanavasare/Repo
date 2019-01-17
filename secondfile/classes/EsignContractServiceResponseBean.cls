/*************************************************************************************************************** 
Apex Class Name     : EsignContractServiceResponseBean
Version             : 1.0 
Created Date        : 5 January 2017
Function            : This class handles the state for the Esign Request Contract Signature Response
*****************************************************************************************************************/
public with sharing class EsignContractServiceResponseBean extends EsignContractInfoBean{

    public String EsignContractResponse;    
    
    public RequestContractSignatureResponse RequestContractSignatureResponse;
 
    public class RequestContractSignatureResponse{
        public WSExceptions WSExceptions;
        public string esignRequestId;
    }
    public class WSExceptions{
        public string Message;
        public string ErrorCode;
    }
}