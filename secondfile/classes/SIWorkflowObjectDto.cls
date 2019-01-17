//A value object which contains the object and associated fields
public with sharing class SIWorkflowObjectDto {
	public String objectLabel {get; set;}
	public String objectApiName {get; set;}
	
	public List<SIWorkflowField> allFieldsList {get; set;}
	public Map<String, List<SIWorkflowField>> dataTypeFieldsMap {get; set;}
	
	//No args Cons
	public SIWorkflowObjectDto() {
		objectLabel = '';
		objectApiName = '';
		allFieldsList = new List<SIWorkflowField>();
		dataTypeFieldsMap = new Map<String, List<SIWorkflowField>>();
		
		for(String dataTypeKey : SIConstants.DATA_TYPE_NAMES) {
			dataTypeFieldsMap.put(dataTypeKey, new List<SIWorkflowField>());
		} 		
	}
	
	//With agrs Cons
	public SIWorkflowObjectDto(String objectLabel, String objectApiName) {
		this();
		this.objectLabel = objectLabel;
		this.objectApiName = objectApiName;
	}
	
	override
	public String toString() {
		return objectLabel +'|'+ objectApiName +'|Fields('+ allFieldsList.size() +')';
	}
	
	//An inner class which holds the fields details
	public class SIWorkflowField {
		public String fieldLabel {get; set;}
		public String fieldApiName {get; set;}
		public String fieldDataType {get; set;}
		
		//No args cons
		public SIWorkflowField() {
			fieldLabel = '';
			fieldApiName = '';
			fieldDataType = '';
		}
		
		//param cons with args
		public SIWorkflowField(String  fieldLabel, 
			String fieldApiName, String fieldDataType) {
			this();
			this.fieldLabel = fieldLabel;
			this.fieldApiName = fieldApiName;
			this.fieldDataType = fieldDataType;
		}
		
		override
		public String toString() {
			return fieldLabel +'|'+ fieldApiName +'|'+ fieldDataType;
		}
	}
}