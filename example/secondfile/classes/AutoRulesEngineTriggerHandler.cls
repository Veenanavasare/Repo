/************************************************************************************************************************************* 
Apex Class Name     : AutoRulesEngineTriggerHandler
Version             : 1.0 
Created Date        : 12 May 2017
Function            : Trigger Handler class for Auto Rules object
*************************************************************************************************************************************/
public class AutoRulesEngineTriggerHandler{
    public Static Boolean stopRecursion = false;
    
    /*Method to trigger mail when Auto Rule is deleted*/
    public void EmailAfterDelete(List<Promotion_Engine__c> AutoRuleOldLst){
        list<OrgWideEmailAddress> owea = new list<OrgWideEmailAddress>();
        owea = [select Id,DisplayName,Address  from OrgWideEmailAddress where Address='partnerexchangesupport@test.amcustomercare.att-mail.com' Limit 1];
        List<Account> alist = [SELECT Id, Name FROM Account];
        List<Contact> clist = [SELECT Id, Name FROM Contact WHERE Contact.AccountId IN :alist];
        List<Messaging.SingleEmailMessage> Listemail = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        EmailTemplate et1=[Select id from EmailTemplate WHERE Name = 'Auto Deal Registration Rule Is Deleted'];
        msg.setTemplateId(et1.id);
        for (Promotion_Engine__c pe : AutoRuleOldLst) {
            msg.setWhatId(pe.id);
        }
        msg.setTargetObjectId(clist[0].Id);
        msg.setSaveAsActivity(false);
        
        msg.setToAddresses(new List<String>{'ARISTOS-SIVAR-IDC@accenture.com'});
        Listemail.add(msg); 
        Savepoint sp = Database.setSavepoint();
        Messaging.sendEmail(Listemail); 
        Database.rollback(sp);  
        
        List<Messaging.SingleEmailMessage> Listemail1 = new List<Messaging.SingleEmailMessage>();
        for (Messaging.SingleEmailMessage email : Listemail) {
            Messaging.SingleEmailMessage abcemail = new Messaging.SingleEmailMessage();
            abcemail.setToAddresses(email.getToAddresses());
            abcemail.setPlainTextBody(email.getPlainTextBody());
            abcemail.setHTMLBody(email.getHTMLBody());
            abcemail.setSubject(email.getSubject());
            Listemail1.add(abcemail);
            String[] toAddresses = new String[]{'EBM_TestingTeam@list.att.com'};
            abcemail.setToAddresses(toAddresses);            
            if(owea != null && owea.size() > 0){
                abcemail.setOrgWideEmailAddressId(owea[0].Id);
            }             
            Messaging.sendEmail(Listemail1);
        }        
    }
    
    /*Method to ensure that there is only one active Category 3 Rule per product at any time*/
    public void checkCategoryThreeRule(list<Promotion_Engine__c> AutoRuleOldLst, list<Promotion_Engine__c> AutoRuleNewLst, map<id,Promotion_Engine__c> OldAutoRuleMap){
        if(!stopRecursion ){
            List<String> ruleName = new List<String>();
            Boolean isMis = false;
            Boolean isAvpn = false;
            Map<String,Promotion_Engine__c> pejMap = new Map<String,Promotion_Engine__c>();
            List<Promotion_Engine__c> updateAutoRuleLst = new List<Promotion_Engine__c>();
            
            for(Promotion_Engine__c pe:AutoRuleNewLst){
                if(pe.Valid_For_Product__c == 'AVPN'){
                    isAvpn = true;
                }
                else if(pe.Valid_For_Product__c == 'MIS'){  
                    isMis = true;
                }
            }
            if(isAvpn){
                ruleName.add('Duplicate SP, EC & AVPN Rule');
                ruleName.add('Duplicate EC & AVPN Rule');
            }
            if(isMis){
                ruleName.add('Duplicate SP, EC & MIS Rule');
                ruleName.add('Duplicate EC & MIS Rule');
            }
            
            List<Promotion_Engine__c> pejLst = new List<Promotion_Engine__c>();
            pejLst = [select id,Promotion_Name__c,Currently_Active__c from Promotion_Engine__c where Promotion_Name__c In: ruleName]; 
            for(Promotion_Engine__c pej:pejLst ){
                pejMap.put(pej.Promotion_Name__c,pej);
            }
            System.debug('pejMap==='+pejMap);
            for(Promotion_Engine__c pe:AutoRuleNewLst){
                if(isAvpn){
                    if(pe.Promotion_Name__c == 'Duplicate EC & AVPN Rule' && pe.Currently_Active__c == true){
                        if(pejMap.size()>0 && pejMap.get('Duplicate SP, EC & AVPN Rule').Currently_Active__c == true){
                            pejMap.get('Duplicate SP, EC & AVPN Rule').Currently_Active__c = false;
                            updateAutoRuleLst.add(pejMap.get('Duplicate SP, EC & AVPN Rule'));
                        }
                    }
                    else if(pe.Promotion_Name__c == 'Duplicate SP, EC & AVPN Rule' && pe.Currently_Active__c == true){
                        if(pejMap.size()>0 && pejMap.get('Duplicate EC & AVPN Rule').Currently_Active__c == true){
                            pejMap.get('Duplicate EC & AVPN Rule').Currently_Active__c = false;
                            updateAutoRuleLst.add(pejMap.get('Duplicate EC & AVPN Rule'));
                        }
                    }
                }
                if(isMis){
                    if(pe.Promotion_Name__c == 'Duplicate EC & MIS Rule' && pe.Currently_Active__c == true){
                        if(pejMap.size()>0 && pejMap.get('Duplicate SP, EC & MIS Rule').Currently_Active__c == true){
                            pejMap.get('Duplicate SP, EC & MIS Rule').Currently_Active__c = false;
                            updateAutoRuleLst.add(pejMap.get('Duplicate SP, EC & MIS Rule'));
                        }
                    }
                    else if(pe.Promotion_Name__c == 'Duplicate SP, EC & MIS Rule' && pe.Currently_Active__c == true){
                        if(pejMap.size()>0 && isMis && pejMap.get('Duplicate EC & MIS Rule').Currently_Active__c == true){
                            pejMap.get('Duplicate EC & MIS Rule').Currently_Active__c = false;
                            updateAutoRuleLst.add(pejMap.get('Duplicate EC & MIS Rule'));
                        }
                    }                    
                }
            }
                    
            if(updateAutoRuleLst != null && updateAutoRuleLst.size() > 0){
                System.debug('updateAutoRuleLst==='+updateAutoRuleLst);
                stopRecursion = true;
                update updateAutoRuleLst;
            }        
        }
    }
}