/******************************************************************************************** 
 Apex Class Name     : ESignQueryContractRequestBean
 Version             : 1.0 
 Created Date        : 12 January 2017
 Function            : ESign Query Contract -- Request Bean 
*********************************************************************************************/

public with sharing class ESignQueryContractRequestBean extends EsignContractInfoBean{

    public QueryContractRequest QueryContractRequest;

    public class QueryContractRequest {
        public ContractGroupIdentifier contractGroupIdentifier;
        public String includeDocuments;
    }

    public class ContractGroupIdentifier {
        public String sourceContractGroupIdentifier;
        public String sourceSystemIdentifier;
        public String ecrmOptyId;
        public String attMANumber;
        public String sourceIdentifier3;
        public String billerId;
        public String pricingScenarioId;
        public String ecrmAccountId;
        public String gcpSolutionId;
        public String pricerDFlag;
        public String esignRequestId;
        public String earningNumber;
    }
    
}