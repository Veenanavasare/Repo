// A factory class which contains the CastIron Objects
public class SICastIronFactory {
	
	//Decorator - Lead Search Results
	public class LeadSearchDecorator implements Comparable {
		public Integer objectCounter {get; set;}
		public String company {get; set;}
		public String dunsNo {get; set;}
		public String romeAccountId {get; set;}
		public String street {get; set;}
		public String city {get; set;}
		public String state {get; set;}
		public String zipCode {get; set;}
		public boolean isSelected {get; set;}
		
		//Default Cons
		public LeadSearchDecorator() {
			objectCounter = 0;
			company = '';
			dunsNo = '';
			romeAccountId = '';
			street = '';
			city = '';
			state = '';
			zipCode = '';
			isSelected = false;
		}
		
		//Params Cons
		public LeadSearchDecorator(Integer objectCounter, String company, String dunsNo, 
			String romeAccountId, String street, String city, String state, String zipCode) {
				this();
				this.objectCounter = objectCounter;
				this.company = company;
				this.dunsNo = dunsNo;
				this.romeAccountId = romeAccountId;
				this.street = street;
				this.city = city;
				this.state = state;
				this.zipCode = zipCode;
		}
		
		override
		public String toString() {
			return company +'|'+ dunsNo;
		}
		
		//method to compare the two objects
		public Integer compareTo(Object wrapperObj) {
			LeadSearchDecorator anotherObject = (LeadSearchDecorator) wrapperObj;
			if(objectCounter > anotherObject.objectCounter) {
				return -1;
			} else if (objectCounter < anotherObject.objectCounter) {
				return 1;
			} 
			return 0;
        }       
		
 	}
 	
 	//Decorator for HeatMap functionality - Will be leveraged the same for external systems if required
 	public class ServiceProductDecorator implements Comparable {
 		
 		public Integer decoratorTrackingId {get; set;}
 		
 		public String accountId {get; set;}
 		public String accountName {get; set;}
 		public String productFamilyName {get; set;}
 		public String productDealStatus {get; set;}
 		
 		public String endCustId {get; set;}
 		public String endCustName {get; set;}
 		public boolean isNamedAccount {get; set;}
 		public Date dealExclusitivityDate {get; set;}
 		public Integer noOfProducts {get; set;}
 	
 		public boolean isSystemApproved {get; set;}
 		public String systemNotation {get; set;}
 		public String colorNameOrCode {get; set;}
 		public boolean isExclusitivityPassed {get; set;}
 		
 		public ServiceProductDecorator() {
			this.accountId = '';
			this.accountName = '';
			this.productFamilyName = '';
			this.productDealStatus = '';
			this.endCustId = '';
			this.endCustName = '';
			this.isNamedAccount = false;
			this.dealExclusitivityDate = Date.today();
			this.noOfProducts = 0;
			this.isSystemApproved = false;
			this.systemNotation = '';
			this.colorNameOrCode = '';
			this.isExclusitivityPassed = false;
 		}
 		//Cons with args
 		public ServiceProductDecorator(
			Integer decoratorTrackingId, String accountId, String accountName, 
			String productFamilyName, String productDealStatus,	String endCustId, 
			String endCustName, boolean isNamedAccount,	Integer noOfProducts, Date dealExclusitivityDate) {
 			this();
 			this.decoratorTrackingId = decoratorTrackingId;
 			this.accountId = accountId;
 			this.accountName = accountName;
 			this.productFamilyName = productFamilyName;
 			this.productDealStatus = productDealStatus;
 			this.endCustId = endCustId;
 			this.endCustName = endCustName;
 			this.isNamedAccount = isNamedAccount;
 			this.dealExclusitivityDate = dealExclusitivityDate;
 			this.noOfProducts = noOfProducts;
 			assignProductSetting();
 		}
 		
 		override
 		public String toString() {
 			return this.endCustName +'|'+ this.accountName +'|'+ this.productFamilyName 
 				+'|'+ systemNotation +'|'+ this.colorNameOrCode;
 		}
 		
 		//provided implementation for Comparable interface
 		public Integer compareTo(Object objectCompare) {
 			ServiceProductDecorator toCompareObject = (ServiceProductDecorator) objectCompare;
 			
 			//Greater than based on account name and product family
 			if((this.accountName.compareTo(toCompareObject.accountName) == 1) && 
 				(this.productFamilyName.compareTo(toCompareObject.productFamilyName) == 1)) {
 				return 1;		
 			}
 			
 			//Equal
 			if((this.accountName.compareTo(toCompareObject.accountName) == 0) && 
 				(this.productFamilyName.compareTo(toCompareObject.productFamilyName) == 0)) {
 				return 0;		
 			}
 			return -1;
 		}
 		
 		//Method to assign the color codes/name
 		private void assignProductSetting() {
 			this.isSystemApproved = SIHelper.doSystemApprovedEntry(productDealStatus);
 			this.systemNotation = isSystemApproved ? 'SYS' : '';
 			this.colorNameOrCode = SIHelper.doSearchColorCodeOrName(
				productDealStatus.length() > 0 ? productDealStatus : 'Available', 
				isNamedAccount
			);
			this.systemNotation += (this.systemNotation.length() 
				== 0 && !isNamedAccount ? '' : '') + '('+noOfProducts+')';
 		}
 	}
}