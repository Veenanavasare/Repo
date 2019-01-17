public with sharing class ESignQueryContractResponseBean extends EsignContractInfoBean{

    public String EsignQueryContractResponse;

    public QueryContractResponse QueryContractResponse;
    
    public class QueryContractResponse {
        public WSResponseHeader WSResponseHeader;
        public WSExceptions WSExceptions;
        public ContractGroup contractGroup;
    }
    
    //WSResponseHeader Block 
    public class WSResponseHeader {
        public WSContext WSContext;
        public String WSCorrelationId;
        public String WSConversationId;
        public WSMessageData WSMessageData;
        public WSEnterpriseLogging WSEnterpriseLogging;
    }
    
    //WSResponseHeader Block -- Section 1 
    public class WSContext {
        public String FromAppId;
        public String ToAppId;
        public Version Version;
        public String SourceIPAddress;
        public List<WSNameValue> WSNameValue;
    }
     
    public class Version {
        public String major;
        public String minor;
    }

    public class WSNameValue {
        public String Name;
        public String Value;
    }
    
    //WSResponseHeader Block -- Section 2 
    public class WSMessageData {
        public String MessageId;
        public String RefToMessageId;
        public String Timestamp;
    }
    
    //WSResponseHeader Block -- Section 3
    public class WSEnterpriseLogging {
        public String ApplicationID;
        public String LoggingKey;
    }
    
    //WSExceptions Block 
    public class WSExceptions {
        public String Message;
        public String ErrorCode;
        public String ErrorType;
        public String FailoverRequired;
        public String RetryRequired;
        public List<AdditionalErrors> AdditionalErrors;
        public List<WSNameValue> WSNameValue;
    }
    
    public class AdditionalErrors {
        public String Message;
        public String ErrorCode;
    }
    
    //ContractGroup Block 
    public class ContractGroup {
        public ContractGroupIdentifier contractGroupIdentifier;
        public CustomerSignatureControl customerSignatureControl;
        public SupplierSignatureControl supplierSignatureControl;
        public StatusControl statusControl;
        public SupplierInfo supplierInfo;
        public CustomerInfo customerInfo;
        public List<ContractList> contractList;
        public String contractGroupAction;
    }
    
    //ContractGroup Block -- Section 1 
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
    
    //ContractGroup Block -- Section 2 
    public class CustomerSignatureControl {
        public String solicitSignature;
        public String allowVoiceSignature;
        public String allowFaxSignature;
        public String allowWebSignature;
        public String sendAutomatically;
        public String sendtoSalesOnly;
        public String sendByFax;
        public String useSingleSignatureCoverPage;
        public String sendExecutedDocsToCustomer;
    }
    
    //ContractGroup Block -- Section 3
    public class SupplierSignatureControl {
        public String solicitSignature;
    }
    
    //ContractGroup Block -- Section 4
    public class StatusControl {
        public String returnSentToCustomerStatus;
        public String returnCustomerSignStatus;
        public String returnSupplierSignStatus;
        public String includeAnnotatedContract;
        public String includeSignatureRecord;
    }
    
    //ContractGroup Block -- Section 5
    public class SupplierInfo {
        public Owner owner;
        public Owner signer;
        public Owner offerDevelopmentManager;
        public String branchID;
        public List<Owner> contact;
        public PersonAddress address;
        public String segment;
        public String companyName;
    }
    
    //ContractGroup Block -- Section 6
    public class CustomerInfo {
        public String companyName;
        public String customerNameOnContract;
        public String countryCode;
        public Owner signer;
        public List<Owner> contact;
        public PersonAddress address;
        public String siteId;
    }
    
    public class Owner {
        public String uniquePersonIdentifier;
        public String firstName;
        public String lastName;
        public String signatureName;
        public String title;
        public String phone;
        public String cellPhone;
        public String email;
        public String foreignIdentifier;
        public PersonAddress personAddress;
    }

    public class PersonAddress {
        public String address1;
        public String address2;
        public String address3;
        public String zipPostCode;
        public String Country;
        public String phone;
        public String fax;
    }
    
    //ContractGroup Block -- Section 7
    public class ContractList {
        public String contractFileName;
        public String contractFileType;
        public String contractFileData;
        public String contractDocumentActionFlag;
        public ContractContent contractContent;
    }    
    
    public class ContractContent {
        public String sourceContractIdentifier;
        public String contractVersionNumber;
        public ContractInformation contractInformation;
    }
    
    public class ContractInformation {
        public String contractDocumentType;
        public String contractBusinessTitle;
        public String contractServiceType;
        public String MContractType;
        public String contractAvailableUntilDate;
        public String contractEffectiveDate;
        public String contractTermMonths;
        public String contractShortDescription;
        public String contractLongDescription;
        public String abnMisPromoIndicator;
        public String eRateRiderIndicator;
        public String shadowContractIndicator;
        public CustomContractDocumentFlags customContractDocumentFlags;
        public String esignContractIdentifier;
        public String status;
    }
    
    public class CustomContractDocumentFlags {
        public String hasNonStandardDesign;
        public String hasNonStandardDiscount;
        public String hasNonStandardPricing;
        public String hasNonStandardOther;
        public String hasNonStandardContractLanguage;
    }
}