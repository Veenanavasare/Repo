/******************************************************************************************** 
 Apex Class Name     : EsignContractRequestBean 
 Version             : 1.0 
 Created Date        : 5 January 2017
 Function            : ESign Request Contract Signature -- Request Bean 
*********************************************************************************************/
public with sharing class EsignContractRequestBean extends EsignContractInfoBean{

    
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
    
    public class CustomContractDocumentFlags {
        public Boolean hasNonStandardDesign;
        public Boolean hasNonStandardDiscount;
        public Boolean hasNonStandardPricing;
        public Boolean hasNonStandardOther;
        public Boolean hasNonStandardContractLanguage;
    }
    
    public class ContractInformation {
        public String contractDocumentType;
        public String contractBusinessTitle;
        public String contractServiceType;
        public String MContractType;
        public DateTime contractAvailableUntilDate;
        public DateTime contractEffectiveDate;
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
    
    public class ContractContent {
        public String sourceContractIdentifier;
        public String contractVersionNumber;
        public ContractInformation contractInformation;
    }
    
    public class ContractList {
        public String contractFileName;
        public String contractFileType;
        public String contractFileData;
        public String contractDocumentActionFlag;
        public ContractContent contractContent;
    }

    public class CustomerInfo {
        public String companyName;
        public String customerNameOnContract;
        public String countryCode;
        public Owner signer;
        public List<Owner> contact;
        public PersonAddress address;
        public String siteId;
    }
    
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
    
    public class StatusControl {
        public Boolean returnSentToCustomerStatus;
        public Boolean returnCustomerSignStatus;
        public Boolean returnSupplierSignStatus;
        public Boolean includeAnnotatedContract;
        public Boolean includeSignatureRecord;
    }
    
    public class SupplierSignatureControl {
        public Boolean solicitSignature;
    }
    
    public class CustomerSignatureControl {
        public Boolean solicitSignature;
        public Boolean allowVoiceSignature;
        public Boolean allowFaxSignature;
        public Boolean allowWebSignature;
        public Boolean sendAutomatically;
        public Boolean sendtoSalesOnly;
        public Boolean sendByFax;
        public Boolean useSingleSignatureCoverPage;
        public Boolean sendExecutedDocsToCustomer;
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
    
    public class RequestContractSignatureRequest {
        public ContractGroup contractGroup;
    }
    
    public RequestContractSignatureRequest RequestContractSignatureRequest;
    
}