trigger EmailAfterDelete on Promotion_Engine__c (before delete) {
    
    list<OrgWideEmailAddress> owea = new list<OrgWideEmailAddress>();
    owea = [select Id,DisplayName,Address  from OrgWideEmailAddress where Address='partnerexchangesupport@amcustomercare.att-mail.com' Limit 1];
    
    
}