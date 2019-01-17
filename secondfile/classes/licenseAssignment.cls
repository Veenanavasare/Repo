public class licenseAssignment
{  
    @future    
    public static void addUserToLicense(Integer addLicense, Set<String> userIds)
    {
        List<UserPackageLicense> apttusProposalLicenseList = new List<UserPackageLicense>();    //List of UserPackageLicense for Apttus Proposal Management license
        List<UserPackageLicense> apttusContractLicenseList = new List<UserPackageLicense>();    //List of UserPackageLicense for Apttus Contract Management license
        List<UserPackageLicense> apttusConfigLicenseList = new List<UserPackageLicense>();      //List of UserPackageLicense for Apttus Configuration & Pricing license
        
        String apttusProposalLicenseId;     //String for Storing Package Id of Apttus Proposal Management
        String apttusContractLicenseId;     //String for Storing Package Id of Apttus Contract Management
        String apttusConfigLicenseId;       //String for Storing Package Id of Apttus Configuration & Pricing
        
        Set<String> apttusProposalUserIdSet = new Set<String>();
        Set<String> apttusContractUserIdSet = new Set<String>();
        Set<String> apttusConfigUserIdSet = new Set<String>();
        
        Map<Id,UserPackageLicense> apttusProposalMap = new Map<Id,UserPackageLicense>();
        Map<Id,UserPackageLicense> apttusContractMap = new Map<Id,UserPackageLicense>();
        Map<Id,UserPackageLicense> apttusConfigMap = new Map<Id,UserPackageLicense>();
        
        List<UserPackageLicense> apttusLicenseListToInsert = new List<UserPackageLicense>();
        Set<UserPackageLicense> apttusLicenseListToDeleteSet = new Set<UserPackageLicense>();
        List<UserPackageLicense> apttusLicenseListToDelete = new List<UserPackageLicense>();
        
        apttusProposalLicenseList = [SELECT UserId, PackageLicenseId, Id, PackageLicense.UsedLicenses, PackageLicense.AllowedLicenses FROM UserPackageLicense  WHERE (PackageLicense.NamespacePrefix = 'Apttus_Proposal')];
        apttusContractLicenseList = [SELECT UserId, PackageLicenseId, Id FROM UserPackageLicense WHERE (PackageLicense.NamespacePrefix = 'Apttus')];
        apttusConfigLicenseList = [SELECT UserId, PackageLicenseId, Id FROM UserPackageLicense WHERE (PackageLicense.NamespacePrefix = 'Apttus_Config2')];
        
        List<String> userNameToLicenseList = new List<String>();
        List<String> userContactToLicenseList = new List<String>();
        List<String> sendTo = new List<String>();
        List<Messaging.SingleEmailMessage> listOfMails = new List<Messaging.SingleEmailMessage>(); 
                
        if(apttusProposalLicenseList[0].PackageLicense.UsedLicenses < apttusProposalLicenseList[0].PackageLicense.AllowedLicenses){    
            if(apttusProposalLicenseList.size()>0){
                for(UserPackageLicense upl1 : apttusProposalLicenseList){
                    if(String.isNotBlank(upl1.UserId)){
                        apttusProposalUserIdSet.add(upl1.UserId);       //Creating Set of Users that have Apttus Proposal Management license
                        apttusProposalMap.put(upl1.UserId,upl1);
                    }
                    if(String.isNotBlank(upl1.PackageLicenseId)){
                        apttusProposalLicenseId = upl1.PackageLicenseId;    //Storing Package Id of Apttus Proposal Management
                    }
                }
            }
            
            if(apttusContractLicenseList.size()>0){
                for(UserPackageLicense upl2 : apttusContractLicenseList){
                    if(String.isNotBlank(upl2.UserId)){
                        apttusContractUserIdSet.add(upl2.UserId);       //Creating Set of Users that have Apttus Contract Management license
                        apttusContractMap.put(upl2.UserId,upl2);
                    }
                    if(String.isNotBlank(upl2.PackageLicenseId)){
                        apttusContractLicenseId = upl2.PackageLicenseId;    //Storing Package Id of Apttus Contract Management
                    }   
                }
            }
            
            if(apttusConfigLicenseList.size()>0){
                for(UserPackageLicense upl3 : apttusConfigLicenseList){
                    if(String.isNotBlank(upl3.UserId)){
                        apttusConfigUserIdSet.add(upl3.UserId);         //Creating Set of Users that have Apttus Configuration & Pricing license
                        apttusConfigMap.put(upl3.UserId,upl3);
                    }
                    if(String.isNotBlank(upl3.PackageLicenseId)){
                        apttusConfigLicenseId = upl3.PackageLicenseId;  //Storing Package Id of Apttus Configuration & Pricing
                    }       
                }
            }
            system.debug('@@@addLicense: '+addLicense);
            if(addLicense == 1){                            //if license needs to be provided to user
                for(String uId : userIds){
                    if(!apttusProposalUserIdSet.contains(uId)){                 //if user does not have Apttus Proposal Management license
                        UserPackageLicense uplA = new UserPackageLicense();
                        uplA.userId = uId;
                        uplA.PackageLicenseId = apttusProposalLicenseId;
                        apttusLicenseListToInsert.add(uplA);
                    }
                    if(!apttusContractUserIdSet.contains(uId)){                 //if user does not have Apttus Contract Management license
                        UserPackageLicense uplB = new UserPackageLicense();
                        uplB.userId = uId;
                        uplB.PackageLicenseId = apttusContractLicenseId;
                        apttusLicenseListToInsert.add(uplB);
                    }
                    if(!apttusConfigUserIdSet.contains(uId)){                   //if user does not have Apttus Configuration & Pricing license
                        UserPackageLicense uplC = new UserPackageLicense();
                        uplC.userId = uId;
                        uplC.PackageLicenseId = apttusConfigLicenseId;
                        apttusLicenseListToInsert.add(uplC);
                    }
                }
            }
        } else {
             List<User> uList = [Select Id, ContactId, Name From User where Id =: userIds];
             for(User u : uList){
                if(String.isNotBlank(u.Name)){
                    userNameToLicenseList.add(u.Name);
                }
                if(String.isNotBlank(u.ContactId)){
                    userContactToLicenseList.add(u.ContactId);
                }
            }
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            //for(User u : [Select Id, Email from User where Profile.Name = 'SI_EBM Admin' AND Email != null AND IsActive = true]){
             sendTo.add('APEX_LICENSE_ISS@list.att.com');
            //}
            if(sendTo.size()>0){
                mail.setToAddresses(sendTo);
            }
            mail.setReplyTo('mech.id.sivar@att.sivar');
            mail.setSenderDisplayName('Mechanized_ID SIVAR');
            mail.setSubject('Apttus License Failure');
              String body = 'Dear EBM Admin, ';
              body += 'Salesforce was unable to correctly assign the Apttus license(s) for the following user. Please ensure that the licenses are manually assigned:';
              body += '<br/>User Name :';
              body += userNameToLicenseList;
              body += '<br/>Contact :';
              body += userContactToLicenseList;
              mail.setHtmlBody(body);
             // listOfMails.add(mail);  //this line must be uncommented for production. It's commented out for testmock only
              
            try{  
                Messaging.sendEmail(listOfMails);
            } catch(Exception e){
                System.Debug('Exception here:'+e.getMessage());
            }
        }
            if(apttusLicenseListToInsert.size()>0){
                try{
                    insert apttusLicenseListToInsert;
                } catch(Exception e){
                    System.Debug('Exception here:'+e.getMessage());
                }
            }

            if(addLicense == 0){                    //if license needs to be revoked from user
                for(String uId : userIds){
                    if(apttusProposalUserIdSet.contains(uId)){                  //if user has Apttus Proposal Management license
                        UserPackageLicense uplD = apttusProposalMap.get(uId);
                        apttusLicenseListToDeleteSet.add(uplD);
                    }
                    if(apttusContractUserIdSet.contains(uId)){                  //if user has Apttus Contract Management license
                        UserPackageLicense uplE = apttusContractMap.get(uId);
                        apttusLicenseListToDeleteSet.add(uplE);
                    }
                    if(apttusConfigUserIdSet.contains(uId)){                    //if user has Apttus Configuration & Pricing license
                        UserPackageLicense uplF = apttusConfigMap.get(uId);
                        apttusLicenseListToDeleteSet.add(uplF);
                    }
                }
            }
            
            if(apttusLicenseListToDeleteSet.size()>0){
                apttusLicenseListToDelete.addAll(apttusLicenseListToDeleteSet);
            }
        
            if(apttusLicenseListToDelete.size()>0){
                try{
                    delete apttusLicenseListToDelete;
                } catch(Exception e){
                    System.Debug('Exception here:'+e.getMessage());
                }
            }
        else
        {
            System.Debug('License Limit Exceeded!!!');
        }
    }
}