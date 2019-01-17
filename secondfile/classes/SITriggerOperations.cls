//A class common to irrespective of trigger implementations
public with sharing class SITriggerOperations {
	
	//An interface holds for all the operations which are triggered 'Before/After' modes
	public interface SITriggerIntf {
		boolean onBeforeInsert(SObject[] newObjects);
		boolean onAfterInsert(SObject[] newObjects);

		boolean onBeforeUpdate(SObject[] oldObjects, SObject[] updatedObjects, Map<Id, SObject>  newObjectsMap);
		boolean onAfterUpdate(SObject[] oldObjects, SObject[] updatedObjects, Map<Id, SObject>  newObjectsMap);
		
		boolean onBeforeDelete(SObject[] oldObjects, Map<Id, SObject>  oldObjectsMap);
		boolean onAfterDelete(SObject[] oldObjects, Map<Id, SObject>  oldObjectsMap);
		
		boolean onUndelete(SObject[] newObjects);
	}
	
	//An implmentation of SITriggerIntf
	public virtual class SITriggerImpl implements SITriggerIntf{
		public SITriggerImpl() {}
		
		//Before Insert Operation
		public  virtual boolean onBeforeInsert(SObject[] newObjects) {
			System.debug('Inside onBeforeInsert');
			return false;
		}
		
		//After Insert
		public  virtual boolean onAfterInsert(SObject[] newObjects) {
			System.debug('Inside onAfterInsert');
			return false;
		}

		//Before Update
		public   virtual boolean onBeforeUpdate(SObject[] oldObjects, SObject[] updatedObjects, Map<Id, SObject>  newObjectsMap) {
			System.debug('Inside onBeforeUpdate');
			return false;
		}
		
		//After Update
		public  virtual boolean onAfterUpdate(SObject[] oldObjects, SObject[] updatedObjects, Map<Id, SObject>  newObjectsMap) {
			System.debug('Inside onAfterUpdate');
			return false;
		}
		
		//Before Delete
		public  virtual boolean onBeforeDelete(SObject[] oldObjects, Map<Id, SObject>  oldObjectsMap) {
			System.debug('Inside onBeforeDelete');
			return false;
		}
		
		//After Delete
		public virtual  boolean onAfterDelete(SObject[] oldObjects, Map<Id, SObject>  oldObjectsMap)  {
			System.debug('Inside onAfterDelete');
			return false;
		}
		
		//On Undelete which will be from recyle-bin to SFDC
		public virtual boolean onUndelete(SObject[] newObjects) {
			System.debug('Inside onUndelete');
			return false;
		}		  
	} //End for Impl class
	
} //End for 'Actual Class'