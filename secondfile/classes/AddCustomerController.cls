/********************************************************************************************** 
 Apex Class Name     : AddCustomerController
 Version             : 1.0 
 Created Date        : 18 Oct 2014
 Function            : This class handles the search and create customer functionalities
***********************************************************************************************/
public with sharing class AddCustomerController {

    private final End_Customer__c atomcus;
    public id duplicateId ; 
    public boolean checkbox {get;set;}
    public AddCustomerController(ApexPages.StandardController controller) {
        this.atomcus=(End_Customer__c)controller.getrecord();
        checkbox = true;
    }
    
    /*Cancel Action Method*/
    public PageReference cancelAction(){        
        return null;
    }

    /*Save Action Method*/
    public PageReference saveAction(){
        try{
            set<id>endCustIDSet = new set<id>() ;
            Boolean duplicate = false;
            user lstUser = [select id, Contact.AccountId from User where id=:userInfo.getUserId()];
            
            if(lstUser.Contact.AccountId != null){
                 list<Account_End_Customer_Junction__c> endCs = [select End_Customer__c, Account__c from Account_End_Customer_Junction__c where  Account__c != NULL  and Account__c =: lstUser.Contact.AccountId];
                 for(Account_End_Customer_Junction__c setid  :endCs){
                     endCustIDSet.add(setid.End_Customer__c);
                 }
                 
                 list<End_Customer__c> Endcustomer = [Select Id,City__c, Office_Phone__c,Business_Website__c,Suite__c,Floor__c,First_Name__c,Company_Legal_Name__c,
                                                       Last_Name__c,Name,Email__c,DUNS__c,State__c,Mailing_Street_Address__c,State_Province__c,Zip__c from End_Customer__c where id in: endCustIDSet];
                 System.debug('--->'+endCustIDSet);
                 for(End_Customer__c Check : Endcustomer){
                    if(Check.Name == atomcus.Name){
                        System.debug('--->+duplicate alert'+Check+'    '+atomcus);
                        duplicateId  = Check.id;
                        duplicate = true;
                        break;
                    }
                }
                
                if(duplicate == true){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Duplicate Address Found. Please add a customer with new address'));
                    PageReference pg = System.Page.Buyflow;
                    pg.getParameters().put('existCustRec',duplicateId );            
                    pg.setRedirect(true);
                    return pg;
                }
                else{
                    insert atomcus;
                    Account_End_Customer_Junction__c junc = new Account_End_Customer_Junction__c( account__c = lstUser.Contact.AccountId, End_Customer__c = atomcus.id);
                    insert junc;
                   
                    //Inserting new customer site with as that of new end customer and tagging it to the same End customer
                    CustomerSite__c customerSite = new CustomerSite__c();
                    if(atomcus != null){
                        customerSite.Site_Name__c = atomcus.Name;
                        customerSite.End_Customer__c = atomcus.Id;
                        customerSite.Address_Line__c = atomcus.Mailing_Street_Address__c;
                        customerSite.City__c = atomcus.City__c;
                        customerSite.State__c = atomcus.State__c;
                        customerSite.Zip_Code__c = atomcus.Zip__c;
                        customerSite.Location__c = atomcus.Suite__c;
                        if(atomcus.Floor__c != null){
                            customerSite.RoomBuildingFloorInput__c = atomcus.Floor__c;
                        }
                    }
                    if(junc !=null){
                        customerSite.Account_End_Customer_Junction__c = junc.Id;
                    }
                    insert customerSite;

                    PageReference pg = System.Page.Buyflow;
                    pg.getParameters().put('newCustRec',atomcus.Id);            
                    pg.setRedirect(true);
                    return pg;
                }
            }else{
                list<account>  acc = new list<account>();
                insert atomcus;
                acc = [select id from account where name = 'AT&T_SP'];
                if(acc.size() == 0){
                    account a= new account( name = 'AT&T_SP');
                    insert a;
                    acc.add(a);
                }
                Account_End_Customer_Junction__c junc = new Account_End_Customer_Junction__c( account__c = acc[0].id, End_Customer__c = atomcus.id);
                insert junc;
                
                PageReference pg = System.Page.Buyflow;
                pg.getParameters().put('newCustRec',atomcus.Id);            
                pg.setRedirect(true);
                return pg;
             }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            ATTException.createException('Error in CreateCustomerController.saveAction', e.getTypeName(), ATTException.constructExceptionMessageString(e));
            return null;
        }
    }


    /*Get values from custom setting for State picklist*/  
    public List<SelectOption> getstatePickList(){
        List<SelectOption> statePickList = new List<SelectOption>();
        List<ATT_StateMapping__c> stateList = ATT_StateMapping__c.getall().values();
        if (stateList!=NULL){
            for(ATT_StateMapping__c item : stateList){
                statePickList.add(new selectoption(item.State_Code__c,item.name));
            }
        }
        statePickList.sort();
        SelectOption placeholderText;
        statePickList.add(0,new SelectOption('','Select'));
        system.debug (' :: ' + statePickList);
        return statePickList;
    }

    /*Get values from custom setting for Location picklist*/    
    public List<SelectOption> getLocationPicklist(){
        try{
            List<SelectOption> locationPicklist = new List<SelectOption>();
            List<ATT_LocationMapping__c> LocationList = ATT_LocationMapping__c.getall().values();
            if (LocationList!=NULL){
                for(ATT_LocationMapping__c item : LocationList){
                    locationPicklist.add(new selectoption(item.name,item.name));
                }
            }
            locationPicklist.sort();
            locationPicklist.add(0,new SelectOption('','Select'));
            return locationPicklist;
        }  
        catch(Exception e){
            ATTException.logException( e.getTypeName(), ATTException.constructExceptionMessageString(e));
            return null;
        }
    }    
}