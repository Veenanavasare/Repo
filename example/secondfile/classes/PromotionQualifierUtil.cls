/*******************************************************************************************************************
 * Class Name: PromotionQualifierUtil
 * Author: Accenture
 * Date: 11-Jan-2018
 * Description: Wireline Promotion Logic Implementation
********************************************************************************************************************/
public class PromotionQualifierUtil{
    Map<String,Set<String>> beforeObjectFields = new Map<String,set<String>>();
    public Map<String,List<String>> promotionsPerSiteMap = new Map<String,List<String>>();
    public List<AT_T_Customer_Site_Quote__c> customerSiteQuoteToBeUpdated;
    public List<String> appliedPromotionsNames = new List<String>();
    public list<Wireline_Promotion_Rules__c> bulkPromotionList;
    
    public void determinePromotion(String id){
        system.debug('@@@Inside Determine Promotion Logic');
        List<String> qualifiedPromotionsQuoteandAccount = new List<String>();
        Date promoSimulationDate;
        Boolean testAccount = false;
        String productCode, productTerm, accountName, spAccountTier, dpeTrialAccount, saoFlag;
        Apttus_Proposal__Proposal__c quote = new Apttus_Proposal__Proposal__c();
        Account account = new Account();
        List<AT_T_Customer_Site_Quote__c> customerSiteQuote = new List<AT_T_Customer_Site_Quote__c>(); 
        list<Wireline_Promotion_Rules__c> eligibleBulkPromotionList = new list<Wireline_Promotion_Rules__c>(); 
      
        CachePromotionValueFetcher cpvf = new CachePromotionValueFetcher();
        try{ 
            List<WirelinPromoObjectAttributes__c> attributeList = WirelinPromoObjectAttributes__c.getall().values();
            List<String> beforeObjectsNameList=new List<String>();
            for(WirelinPromoObjectAttributes__c attribute : attributeList){
               beforeObjectsNameList.add(attribute.value__c);
            } 
            system.debug('@@@beforeObjectsNameList: '+beforeObjectsNameList);
            Map<String,Set<String>> metaData = (Map<String,Set<String>>)Cache.Org.get(PromotionMetaData.class,'ALLMETADATA');
            System.debug('Meta Data: ' + metaData);
            
            System.debug(metaData.get('Apttus_Proposal__Proposal__c'));
            String metaFields=String.join(new List<String>(metaData.get('Apttus_Proposal__Proposal__c')),',');
            System.debug('@@@metaFields: '+metaFields);
                 
            String quoteQuery='select id, Apttus_Proposal__Account__r.id,Promotion_Simulation_Date__c,Apttus_Proposal__Account__r.Test_Company__c,'+metaFields+' from Apttus_Proposal__Proposal__c WHERE id =:id Limit 1';
            System.debug('Quote query: ' + quoteQuery);
            quote=database.query(quoteQuery); 
            system.debug('currentQuote '+quote);
            productCode = quote.ProdCode__c;            
            productTerm = quote.Apttus_Proposal__Payment_Term__c;
            
            String quoteStr = String.valueOf(quote).subStringAfter('{');
            quoteStr = quoteStr.remove('}');
            System.debug('quoteStr: '+ quoteStr); 
            List<String> quoteValue = quoteStr.split(',');

            for(integer i =2;i<quoteValue.size();i++){                
                if(quoteValue[i].split('=')[0].trim() != 'NumberofSites__c'){
                    System.debug('quote field: ' + quoteValue[i].split('=')[0]+ ' quoteValue: '+ quoteValue[i].split('=')[1]);
                    list<String> qp = new list<String>();
                    qp = (List<String>)cpvf.get(quoteValue[i].split('=')[1]);
                    if(qp!= null && qp.size()>0)
                        qualifiedPromotionsQuoteandAccount.addall(qp);
                }
            }
            system.debug('@@@qualifiedPromotionsQuoteandAccount: '+qualifiedPromotionsQuoteandAccount);
            
            String AccmetaFields=String.join(new List<String>(metaData.get('Account')),',');
            System.debug('Account fields are: '+AccmetaFields);
            Id accountId = quote.Apttus_Proposal__Account__r.id;
            Id quoteObj = quote.id;
            promoSimulationDate = quote.Promotion_Simulation_Date__c;
            testAccount = quote.Apttus_Proposal__Account__r.Test_Company__c;  
            
            String accountQuery = 'select '+AccmetaFields+' from Account WHERE id =:accountId Limit 1';
            account = database.query(accountQuery);        
            if(account.Name.contains(',')){
                account.Name = account.Name.replaceAll(',','');
            }
            accountName = account.Name;
            spAccountTier = account.SP_Tier__c;
            dpeTrialAccount = account.DPE_Trial_Formula__c;
            saoFlag = account.SAO_Formula__c; 
            
            String accountStr = String.valueOf(account).subStringAfter('{');
            accountStr = accountStr.remove('}');
            System.debug('accountStr: '+ accountStr); 
            List<String> accountValue = accountStr.split(',');
            
            for(integer i =0;i<accountValue.size();i++){
                List<String> qp = (List<String>)cpvf.get(accountValue[i].split('=')[1]);
                if (qp!=null)
                    qualifiedPromotionsQuoteandAccount.addall(qp);
            }
            system.debug('@@@qualifiedPromotionsQuoteandAccount: '+qualifiedPromotionsQuoteandAccount);      
                  
            String sitemetaFields=String.join(new List<String>(metaData.get('CustomerSite__c')),',');
            String siteQuery = 'select AT_T_Quote__r.Apttus_Proposal__Opportunity__c,AT_T_Quote__r.Apttus_Proposal__Opportunity__r.Deal_Reg_Approved__c,AT_T_Quote__r.Apttus_Proposal__Opportunity__r.StageName,Wireline_Promotion_Id_Sorted__c,Wireline_Promotion_Id_Before__c,Wireline_Promotion_Id_After__c, ' + sitemetaFields + ' from AT_T_Customer_Site_Quote__c where AT_T_Quote__c =:id'; 
            System.debug('site query: ' + siteQuery);
            customerSiteQuote = database.query(siteQuery); 
            System.debug('Customer sites: ' + customerSiteQuote.size());
            
            List<AT_T_Customer_Site_Quote__c> junctionsToBeUpdated = new List<AT_T_Customer_Site_Quote__c>();
            
            bulkPromotionList = new list<Wireline_Promotion_Rules__c>();   
            if(promoSimulationDate == null){
                if(testAccount == false){
                    bulkPromotionList = [SELECT id,name,Field_Inputs__c,Active__c,Promotion_Certified__c,Do_Not_Run__c,Expired__c,Bulk_Promotion__c,Bulk_Criteria_Field_Name__c,Bulk_Criteria_Field_Value__c FROM Wireline_Promotion_Rules__c WHERE Promo_Type__c = 'Access' AND Active__c = TRUE AND Do_Not_Run__c = FALSE AND Expired__c = FALSE AND Promotion_Certified__c = TRUE AND For_Testing__c = FALSE AND Bulk_Promotion__c = TRUE];
                    system.debug('@@@Inside 1: '+bulkPromotionList);
                }else{
                    bulkPromotionList = [SELECT id,name,Field_Inputs__c,Active__c,Promotion_Certified__c,Do_Not_Run__c,Expired__c,Bulk_Promotion__c,Bulk_Criteria_Field_Name__c,Bulk_Criteria_Field_Value__c FROM Wireline_Promotion_Rules__c WHERE Promo_Type__c = 'Access' AND Active__c = TRUE AND Do_Not_Run__c = FALSE AND Expired__c = FALSE AND Bulk_Promotion__c = TRUE];
                    system.debug('@@@Inside 2: '+bulkPromotionList);
                }
            }
            else{
                if(testAccount == false){
                    bulkPromotionList = [SELECT id,name,Field_Inputs__c,Start_Date__c,End_Date__c,Active__c,For_Testing__c,Promotion_Certified__c,Do_Not_Run__c,Expired__c,Bulk_Promotion__c,Bulk_Criteria_Field_Name__c,Bulk_Criteria_Field_Value__c FROM Wireline_Promotion_Rules__c WHERE Promo_Type__c = 'Access' AND Start_Date__c <= :promoSimulationDate AND End_Date__c >= :promoSimulationDate AND Do_Not_Run__c = FALSE AND Expired__c = FALSE AND For_Testing__c = FALSE AND Bulk_Promotion__c = TRUE];
                    system.debug('@@@Inside 3: '+bulkPromotionList);
                }else{
                    bulkPromotionList = [SELECT id,name,Field_Inputs__c,Start_Date__c,End_Date__c,Active__c,For_Testing__c,Promotion_Certified__c,Do_Not_Run__c,Expired__c,Bulk_Promotion__c,Bulk_Criteria_Field_Name__c,Bulk_Criteria_Field_Value__c FROM Wireline_Promotion_Rules__c WHERE Promo_Type__c = 'Access' AND Start_Date__c <= :promoSimulationDate AND End_Date__c >= :promoSimulationDate AND Do_Not_Run__c = FALSE AND Expired__c = FALSE AND Bulk_Promotion__c = TRUE];
                    system.debug('@@@Inside 4: '+bulkPromotionList);
                }
            }            
            system.debug('@@@Bulk Promotion List: '+ bulkPromotionList);        
            
            for(Wireline_Promotion_Rules__c wprRule : bulkPromotionList){
                if(wprRule.Field_Inputs__c != null){
                    String fieldInputs = wprRule.Field_Inputs__c.replaceAll('"','');
                    Boolean bulkPromotionEligible = true;
                    for(String sectionNameAndValue : fieldInputs.split('\\|')){
                        system.debug('@@@Promo Id: '+ wprRule.Id+' @@@Map: '+sectionNameAndValue);
                        if(sectionNameAndValue.split(':')[0] == 'Product' && sectionNameAndValue.split(':').size() > 1){
                            if(sectionNameAndValue.split(':')[1] != null && sectionNameAndValue.split(':')[1] != '' && !sectionNameAndValue.split(':')[1].split(';').contains(productCode)){
                                bulkPromotionEligible = false;
                                system.debug('@@@Product Not Eligible!!!');
                                break;
                            }
                        }    
                        if(sectionNameAndValue.split(':')[0] == 'SP Tier' && sectionNameAndValue.split(':').size() > 1){
                            if(sectionNameAndValue.split(':')[1] != null && sectionNameAndValue.split(':')[1] != '' && !sectionNameAndValue.split(':')[1].split(';').contains(spAccountTier)){
                                bulkPromotionEligible = false;
                                system.debug('@@@SP Tier Not Eligible!!!');
                                break;
                            }
                        }
                        if(sectionNameAndValue.split(':')[0] == 'Term' && sectionNameAndValue.split(':').size() > 1){
                            if(sectionNameAndValue.split(':')[1] != null && sectionNameAndValue.split(':')[1] != '' && !sectionNameAndValue.split(':')[1].split(';').contains(productTerm)){
                                bulkPromotionEligible = false;
                                system.debug('@@@Term Not Eligible!!!');
                                break;
                            }
                        }
                        if(sectionNameAndValue.split(':')[0] == 'Site Quote Type' && sectionNameAndValue.split(':').size() > 1 && customerSiteQuote.size()> 0 && String.isNotBlank(customerSiteQuote[0].Portal_Site_Formula__c)){
                            if(sectionNameAndValue.split(':')[1] != null && sectionNameAndValue.split(':')[1] != '' && customerSiteQuote[0].Portal_Site_Formula__c == 'Portal' && !sectionNameAndValue.split(':')[1].split(';').contains(customerSiteQuote[0].Portal_Site_Formula__c)){
                                bulkPromotionEligible = false;
                                system.debug('@@@Portal Type Not Eligible!!!');
                                break;
                            }                        
                        }
                        if(sectionNameAndValue.split(':')[0] == 'Site Quote Type' && sectionNameAndValue.split(':').size() > 1 && customerSiteQuote.size()> 0 && String.isNotBlank(customerSiteQuote[0].API_IPQ_Site_Formula__c)){
                            if(sectionNameAndValue.split(':')[1] != null && sectionNameAndValue.split(':')[1] != '' && customerSiteQuote[0].API_IPQ_Site_Formula__c == 'API' && !sectionNameAndValue.split(':')[1].split(';').contains(customerSiteQuote[0].API_IPQ_Site_Formula__c)){
                                bulkPromotionEligible = false;
                                system.debug('@@@API Type Not Eligible!!!');  
                                break;      
                            }
                        }    
                        if(sectionNameAndValue.split(':')[0] == 'SP List' && sectionNameAndValue.split(':').size() > 1){
                            if(sectionNameAndValue.split(':')[1] != null && sectionNameAndValue.split(':')[1] != '' && !sectionNameAndValue.split(':')[1].replaceAll(',','').split(';').contains(accountName)){
                                bulkPromotionEligible = false;
                                system.debug('@@@Account Not Eligible!!!');
                                break;
                            }
                        }
                        if(sectionNameAndValue.split(':')[0] == 'DPE Trial' && sectionNameAndValue.split(':').size() > 1){
                            if(sectionNameAndValue.split(':')[1] != null && sectionNameAndValue.split(':')[1] != '' && sectionNameAndValue.split(':')[1] == 'DPE Trial' && dpeTrialAccount != 'DPE Trial'){
                                bulkPromotionEligible = false;
                                system.debug('@@@DPE Trial Account Type Not Eligible!!!');
                                break;
                            }
                        }
                        if(sectionNameAndValue.split(':')[0] == 'SAO' && sectionNameAndValue.split(':').size() > 1){
                            if(sectionNameAndValue.split(':')[1] != null && sectionNameAndValue.split(':')[1] != '' && ((saoFlag == 'SAO' && !sectionNameAndValue.split(':')[1].split(';').contains('SAO')) || (saoFlag != 'SAO' && !sectionNameAndValue.split(':')[1].split(';').contains('Non SAO')))){
                                bulkPromotionEligible = false;
                                system.debug('@@@SAO Account Type Not Eligible!!!');
                                break;
                            }
                        }
                    }                    
                    if(bulkPromotionEligible == true){
                        system.debug('@@@Bulk Promotion Checks Cleared!!!');
                        eligibleBulkPromotionList.add(wprRule);
                    }
                }                
            }
            system.debug('@@@eligibleBulkPromotionList: '+eligibleBulkPromotionList);
            
            //Logic End
            for(AT_T_Customer_Site_Quote__c csq : customerSiteQuote){
                List<String> qPromotionsQuoteandAccount = new List<String>();  
                List<String> qPromotions = new List<String>();
                Map<String,integer> quailiedPromotionsWithMatches = new Map<String,integer>();
                String siteStr = String.valueOf(csq).subStringAfter('{');
                siteStr = siteStr.remove('}');
                List<String> siteValue = siteStr.split(',');
                for (integer i =0;i<siteValue.size();i++){
                    System.debug('site Value is: ' + siteValue);        
                    List<String> qp = new List<String>();
                    if(siteValue[i].split('=').size() <=1){
                        System.debug('Site value is not good for split: ' + siteValue);                  
                        continue; 
                    }
                    System.debug('site field: ' + siteValue[i].split('=')[0]+ ' siteValue: '+ siteValue[i].split('=')[1]);
                    if((siteValue[i].split('=')[0]).trim().equals('Alternate_Access_Building_CLLI__c')){
                        qp = (List<String>)cpvf.get(siteValue[i].split('=')[1]+'$BClli');
                    }else if ((siteValue[i].split('=')[0]).trim().equals('Pricing_Tier__c')){
                        qp = (List<String>)cpvf.get(siteValue[i].split('=')[1]+'$PTier');
                    }else if ((siteValue[i].split('=')[0]).trim().equals('Qualification_Tier__c')){
                        qp = (List<String>)cpvf.get(siteValue[i].split('=')[1]+'$QTier');
                    }else if ((siteValue[i].split('=')[0]).trim().equals('Core_Based_Statistical_Area_Code__c')){
                        qp = (List<String>)cpvf.get(siteValue[i].split('=')[1]+'$CBSA');
                    }else if ((siteValue[i].split('=')[0]).trim().equals('Access_Speed_Generic__c')){
                        qp = (List<String>)cpvf.get(siteValue[i].split('=')[1]+'$ACC');
                    }else if((siteValue[i].split('=')[0]).trim().equals('Alternate_Access_vendorName__c')){
                        system.debug('@@@ITPA LEC: '+siteValue[i]);
                        qp = (List<String>)cpvf.get(siteValue[i].split('=')[1]+'$ITPA');
                    }else if((siteValue[i].split('=')[0]).trim().equals('ITPA_LEC_Contains__c')){
                        system.debug('@@@ITPA LEC Contains: '+siteValue[i]);
                        set<String> itpaLECSet = new set<String>();
                        for(String str : siteValue[i].split('=')[1].split(' ')){                                                       
                            if((List<String>)cpvf.get(str+'$ITPAC') != null){                                
                                if(!itpaLECSet.contains(str+'$ITPAC')){
                                    system.debug('@@@ITPA LEC Contains String: '+str); 
                                    itpaLECSet.add(str+'$ITPAC');
                                    qp.addAll((List<String>)cpvf.get(str+'$ITPAC'));
                                }
                            }
                        }
                    }else if((siteValue[i].split('=')[0]).trim().equals('VASA_LEC__c')){
                        system.debug('@@@VASA LEC Contains: '+siteValue[i]);
                        qp = (List<String>)cpvf.get(siteValue[i].split('=')[1]+'$VASA');
                    }else if((siteValue[i].split('=')[0]).trim().equals('Original_VASA_LEC_Contains__c')){
                        set<String> vasaLECSet = new set<String>();
                        for(String str : siteValue[i].split('=')[1].split(' ')){
                            if((List<String>)cpvf.get(str+'$VASAC') != Null){
                                if(!vasaLECSet.contains(str+'$VASAC')){
                                    system.debug('@@@VASA LEC Contains String: '+siteValue[i]);
                                    vasaLECSet.add(str+'$VASAC');
                                    qp.addAll((List<String>)cpvf.get(str+'$VASAC'));
                                }
                            }
                        }
                    }else{
                        qp = (List<String>)cpvf.get(siteValue[i].split('=')[1]);
                    }
                    System.debug('qp value is: ' + qp);
                    if (qp!=null){
                        qPromotions.addall(qp);
                    }
                }
                system.debug('@@@qPromotions: '+qPromotions);
                system.debug('@@@qualifiedPromotionsQuoteandAccount: '+qualifiedPromotionsQuoteandAccount);
                                
                qPromotionsQuoteandAccount.addAll(qualifiedPromotionsQuoteandAccount);
                qPromotionsQuoteandAccount.addAll(qPromotions);
                quailiedPromotionsWithMatches = qualifiyPromotions(qPromotionsQuoteandAccount);
                system.debug('@@@quailiedPromotionsWithMatches: '+quailiedPromotionsWithMatches);
                Map<String,List<String>> bap = beforeandAfterPromotions(quailiedPromotionsWithMatches, promoSimulationDate, testAccount);
                system.debug('@@@bap: '+bap);
                
                Map<String,List<String>> finalPromoMap = determineBulkPromotionEligiblity(bap,account,quote,csq,eligibleBulkPromotionList);
                System.debug('@@@Sorted Promotions: '+promotionTypeBasedLists(finalPromoMap));
                List<String> sortedPromotions = promotionTypeBasedLists(finalPromoMap);              
                junctionsToBeUpdated.add(updateQuoteJunctionWithPromotions(bap,sortedPromotions,csq));
            }
            if(junctionsToBeUpdated.size() > 0){
                update junctionsToBeUpdated;
            }
        }
        catch(Exception e){
            system.debug('Exception in LookForNewPromotions method of PromotionQualifierUtil: '+e+' at line no '+e.getLineNumber()+ '  Message - >'+ e.getMessage());        
        }
    }
      
    public Map<String,integer> qualifiyPromotions(List<String> qualifiedPromotions){
        Map<String,integer> quailiedPromotionsWithMatches = new Map<String,integer>();
        for(String qp : qualifiedPromotions){
            System.debug(qp.split('_')[0]);
            integer times = quailiedPromotionsWithMatches.get(qp);
            system.debug('@@@times: '+times);
            if (times != null && times >=1){
               times++;
            }
            else{
               times = 1;
            }
            quailiedPromotionsWithMatches.put(qp,times);
        }
        system.debug('@@@quailiedPromotionsWithMatches: '+quailiedPromotionsWithMatches);
        return quailiedPromotionsWithMatches;
    }
     
    public Map<String,List<String>> beforeandAfterPromotions(Map<String,integer> quailiedPromotionsWithMatches, Date promoSimulationDate, Boolean testAccount){
        Map<String,List<String>> bap = new Map<String,List<String>>();
        Set<String> promoKeySet = quailiedPromotionsWithMatches.KeySet();
        List<String> beforePromotionList = new List<String>();
        List<String> afterPromotionList = new List<String>();   
        try{ 
            Map<Id,Wireline_Promotion_Rules__c> wprMap = Promotion.getAll();
            for(String promoId : promoKeySet){   
                system.debug('Promo Id: '+promoId);                 
                Wireline_Promotion_Rules__c wpr = wprMap.get(promoId.split('_')[0]);
                System.debug('look for me promo id: '+ promoId.split('_')[0]);
                Decimal configuredFields = 0;
                Decimal configuredBeforeFields = 0;

                if(wpr != null && wpr.Configured_Fields_Number__c != null){
                    configuredFields = wpr.Configured_Fields_Number__c;
                }
                if(wpr != null && wpr.Configured_Fields_Before__c != null){
                    configuredBeforeFields = wpr.Configured_Fields_Before__c;
                }
                
                if(promoSimulationDate == null){
                    if(testAccount == false){
                        if(wpr != null && ((wpr.Configured_Fields_Number__c <= 0 && wpr.Active__c && !wpr.Do_Not_Run__c) || !wpr.Active__c || wpr.For_Testing__c)){
                            system.debug('inside promoSimulationDate - Non Test Account'+wpr.Id);
                            continue;
                        }
                    }else{
                        if(wpr != null && ((wpr.Configured_Fields_Number__c <= 0 && wpr.Active__c && !wpr.Do_Not_Run__c) || !wpr.Active__c )){
                            system.debug('inside promoSimulationDate - Test Account'+wpr.Id);
                            continue;
                        }
                    }
                }else{
                    if(testAccount == false){
                        if(wpr != null && (wpr.Configured_Fields_Number__c <= 0 || wpr.Start_Date__c > promoSimulationDate || wpr.End_Date__c < promoSimulationDate || wpr.Do_Not_Run__c || wpr.For_Testing__c)){
                            system.debug('inside promoSimulationDate not null continue'+wpr.Id);
                            continue;
                        }
                    }else{
                        if(wpr != null && (wpr.Configured_Fields_Number__c <= 0 || wpr.Start_Date__c > promoSimulationDate || wpr.End_Date__c < promoSimulationDate || wpr.Do_Not_Run__c )){
                            system.debug('inside promoSimulationDate not null continue'+wpr.Id);
                            continue;
                        }
                    }
                }
               
                System.debug('look for me Promo id: ' + promoId);
                System.debug('configuredBeforeFields  ' + configuredBeforeFields);   
                System.debug('configured  ' + configuredFields );   
                System.debug('quailiedPromotionsWithMatches.get(promoId) ' + quailiedPromotionsWithMatches.get(promoId));  
                System.debug('condition for before: ' + (configuredFields > quailiedPromotionsWithMatches.get(promoId)));  
                System.debug('condition for before: ' + (configuredBeforeFields == quailiedPromotionsWithMatches.get(promoId)));
                
                if ( configuredFields <=  quailiedPromotionsWithMatches.get(promoId) && configuredBeforeFields == quailiedPromotionsWithMatches.get(promoId)){
                       beforePromotionList.add(promoId);
                }           
                if (configuredFields > quailiedPromotionsWithMatches.get(promoId) && configuredBeforeFields == quailiedPromotionsWithMatches.get(promoId)){
                       afterPromotionList.add(promoId);
                }
            }
            system.debug('@@@beforePromotionList: '+beforePromotionList);
            system.debug('@@@afterPromotionList: '+afterPromotionList);
           
            Set<Id> wprIdSet = wprMap.keySet();
            for (Id wprId: wprIdSet){
                Wireline_Promotion_Rules__c wp = wprMap.get(String.valueOf(wprId));
                if(promoSimulationDate == null){
                    if(testAccount == false){
                        if(wp.Configured_Fields_Before__c == 0 && wp.Active__c == true && wp.Promotion_Certified__c == true && wp.Do_Not_Run__c == false && wp.For_Testing__c == false){
                            afterPromotionList.add(String.valueOf(wp.Id)+'_'+wp.Promo_Type__c);
                            system.debug('@@@Non-Test Account - Promotion Simulation Date is NULL: '+wp.Id);
                        }
                    }else{
                        if(wp.Configured_Fields_Before__c == 0 && wp.Active__c == true && wp.Do_Not_Run__c == false){
                            afterPromotionList.add(String.valueOf(wp.Id)+'_'+wp.Promo_Type__c);
                            system.debug('@@@Test Account - Promotion Simulation Date is NULL: '+wp.Id);
                        }
                    }
                }
                else{
                    if(testAccount == false){
                        if(wp.Configured_Fields_Before__c == 0 &&  wp.Start_Date__c <= promoSimulationDate && wp.End_Date__c >= promoSimulationDate && !wp.Do_Not_Run__c && wp.For_Testing__c == false){
                            afterPromotionList.add(String.valueOf(wp.Id)+'_'+wp.Promo_Type__c);
                            system.debug('@@@Non-Test Account - Promotion Simulation Date is NOT NULL: '+wp.Id);
                        }
                    }else{
                        if(wp.Configured_Fields_Before__c == 0 &&  wp.Start_Date__c <= promoSimulationDate && wp.End_Date__c >= promoSimulationDate && !wp.Do_Not_Run__c ){
                            afterPromotionList.add(String.valueOf(wp.Id)+'_'+wp.Promo_Type__c);
                            system.debug('@@@Test Account - Promotion Simulation Date is NOT NULL: '+wp.Id);
                        }
                    }
                }
            }
            
            bap.put('before',beforePromotionList);
            System.debug('before promotions are: ' + bap.get('before'));
               
            bap.put('after',afterPromotionList);
            system.debug('---after promotion---'+afterPromotionList);
        }
        catch(Exception e){
            system.debug('Exception in beforeandAfterPromotions method of PromotionQualifierUtil'+e+' at line no '+e.getLineNumber()+ '  Message - >'+ e.getMessage());        
        }
        return bap;
    }
     
    public List<String> promotionTypeBasedLists(Map<String,List<String>> bap){
        Map<Decimal,String> portPromotions = new Map<Decimal,String>();
        Map<Decimal,String> accessPromotions = new Map<Decimal,String>();
        Map<Decimal,String> featurePromotions = new Map<Decimal,String>();
        Map<Decimal,String> spPromotions = new Map<Decimal,String>();
        Map<Decimal,String> orderPromotions = new Map<Decimal,String>();
        Map<Decimal,String> dealRegPromotions = new Map<Decimal,String>();
        Map<Decimal,String> spTierPromotions = new Map<Decimal,String>();
        Map<Decimal,String> rateCardMapPromotions = new Map<Decimal,String>();
         
        List<String> beforeAndAfterPromotionListSorted = new List<String>();
        List<String> beforeAndAfterPromoList = new List<String>();

        beforeAndAfterPromoList.addAll(bap.get('before'));
        beforeAndAfterPromoList.addAll(bap.get('after'));
      
        for (String promotionId : beforeAndAfterPromoList){
            String promoType = promotionId.split('_')[1];
            Wireline_Promotion_Rules__c wpr = Promotion.get(promotionId.split('_')[0]);
            if(promoType.equalsIgnoreCase('Port')){
                portPromotions.put(wpr.Rank__c,promotionId);
            }
            if(promoType.equalsIgnoreCase('Access')){
                accessPromotions.put(wpr.Rank__c,promotionId);
            }
            if(promoType.equalsIgnoreCase('SP Tier Discount')){
                spTierPromotions.put(wpr.Rank__c,promotionId);
            }
            if(promoType.equalsIgnoreCase('SP')){
                spPromotions.put(wpr.Rank__c,promotionId);
            }
            if(promoType.equalsIgnoreCase('feature')){
                featurePromotions.put(wpr.Rank__c,promotionId);
            }
            if(promoType.equalsIgnoreCase('deal reg')){
                dealRegPromotions.put(wpr.Rank__c,promotionId);
            }
            if(promoType.equalsIgnoreCase('order')){
                orderPromotions.put(wpr.Rank__c,promotionId);
            }
            if(promoType.equalsIgnoreCase('Rate Card Map')){
                rateCardMapPromotions.put(wpr.Rank__c,promotionId);
            }
        }
        beforeAndAfterPromotionListSorted.addAll(promotionSorter(rateCardMapPromotions));
        beforeAndAfterPromotionListSorted.addAll(promotionSorter(portPromotions));
        beforeAndAfterPromotionListSorted.addAll(promotionSorter(accessPromotions));
        beforeAndAfterPromotionListSorted.addAll(promotionSorter(featurePromotions));
        beforeAndAfterPromotionListSorted.addAll(promotionSorter(spPromotions));
        beforeAndAfterPromotionListSorted.addAll(promotionSorter(spTierPromotions));
        beforeAndAfterPromotionListSorted.addAll(promotionSorter(dealRegPromotions));
        beforeAndAfterPromotionListSorted.addAll(promotionSorter(orderPromotions));
        system.debug('@@@beforeAndAfterPromotionListSorted: '+beforeAndAfterPromotionListSorted);
        return beforeAndAfterPromotionListSorted;
    }
      
    public List<string> promotionSorter(Map<Decimal,String> promotionList){
        List<String> beforeAndAfterPromotionListSorted= new List<String>();  
        List<decimal> rank = new List<decimal>();
        rank.addAll(promotionList.keySet());
        rank.sort();  
        for(decimal r: rank){
            beforeAndAfterPromotionListSorted.add(promotionList.get(r));        
        }
        system.debug('@@@beforeAndAfterPromotionListSorted: '+beforeAndAfterPromotionListSorted);
        return beforeAndAfterPromotionListSorted;
    }
      
    public AT_T_Customer_Site_Quote__c updateQuoteJunctionWithPromotions(Map<String,List<String>> bap,List<String> sortedPromotions,AT_T_Customer_Site_Quote__c csq){
        csq.Wireline_Promotion_Id_After__c = String.Join(bap.get('after'),',');
        csq.Wireline_Promotion_Id_Before__c = String.join(bap.get('before'),',');
        csq.Wireline_Promotion_Id_Before__c = csq.Wireline_Promotion_Id_Before__c;
        csq.Wireline_Promotion_Id_Sorted__c  = String.join(sortedPromotions,',');
        system.debug('@@@csq: '+csq);
        return csq;
    }
      
    public List<String> determineStackablity(List<String> promotionsList,Map<Id,Wireline_Promotion_Rules__c> wprMap){
        List<String> portPromotion = new List<String>();
        List<String> accessPromotion = new List<String>();
        List<String> rateCardPromotion = new List<String>();
        List<String> featurePromotion = new List<String>();
        List<String> spPromotion = new List<String>();
        List<String> orderPromotion = new List<String>();
        List<String> dealRegPromotion = new List<String>();
        List<String> toBeAppliedpromotions = new List<String>();
        
        Map<Decimal,String> portPromotionMapWithRank = new Map<Decimal,String>();
        Map<Decimal,String> accessPromotionMapWithRank = new Map<Decimal,String>();
        Map<Decimal,String> rateCardPromotionMapWithRank = new Map<Decimal,String>();
        Map<Decimal,String> featurePromotionMapWithRank = new Map<Decimal,String>();
        Map<Decimal,String> spPromotionMapWithRank = new Map<Decimal,String>();
        Map<Decimal,String> orderPromotionMapWithRank = new Map<Decimal,String>();
        Map<Decimal,String> dealRegPromotionMapWithRank = new Map<Decimal,String>(); 
        
        for(String promo : promotionsList){
            Wireline_Promotion_Rules__c wpr = wprMap.get(promo.split('_')[0]);
            if(promo.split('_')[1].equalsIgnoreCase('port')){
                System.debug('looking into stackability for port: ' + promo);
                portPromotion.add(promo); 
                portPromotionMapWithRank.put(wpr.Rank__c,promo);
            }
            if(promo.split('_')[1].equalsIgnoreCase('access')){
                accessPromotion.add(promo);
                accessPromotionMapWithRank.put(wpr.Rank__c,promo);
            }
            if(promo.split('_')[1].equalsIgnoreCase('rateCard')){
                rateCardPromotion.add(promo);
                rateCardPromotionMapWithRank.put(wpr.Rank__c,promo);
            }
            if(promo.split('_')[1].equalsIgnoreCase('feature')){
                System.debug('adding promotion for feature: ' + promo);
                featurePromotion.add(promo);
                featurePromotionMapWithRank.put(wpr.Rank__c,promo);
            }
            if(promo.split('_')[1].equalsIgnoreCase('sp')){
                spPromotion.add(promo);
                spPromotionMapWithRank.put(wpr.Rank__c,promo);
            }
            if(promo.split('_')[1].equalsIgnoreCase('Order')){
                orderPromotion.add(promo);
                orderPromotionMapWithRank.put(wpr.Rank__c,promo);
            }
            if(promo.split('_')[1].equalsIgnoreCase('dealReg')){
                dealRegPromotion.add(promo);
                dealRegPromotionMapWithRank.put(wpr.Rank__c,promo);
            }                                      
        }
        
        Boolean stackability = false;
        portPromotion.clear();
        portPromotion = promotionSorter(portPromotionMapWithRank);
        for(String prm : portPromotion){
            Wireline_Promotion_Rules__c wpr = wprMap.get(prm.split('_')[0]);
            System.debug('checking for stacability: ' + prm);
            System.debug('stackability flag is: ' + wpr.Stackable__c);
            if ( wpr != null){
                if(!wpr.Stackable__c && !stackability){
                    system.debug('---prm---'+prm);
                    toBeAppliedpromotions.add(prm);
                    stackability = true;
                } 
            }
        }
        
        if(!stackability){
            toBeAppliedpromotions.addAll(portPromotion); 
        }
        else{
            stackability = false;              
        }
        accessPromotion.clear();
        accessPromotion = promotionSorter(accessPromotionMapWithRank);
        for(String prm : accessPromotion){
            Wireline_Promotion_Rules__c wpr = wprMap.get(prm.split('_')[0]);
            if(wpr != null){
                if(!wpr.Stackable__c && !stackability){
                    toBeAppliedpromotions.add(prm);
                    stackability = true;
                } 
            }
        }
        
        if(!stackability){
            toBeAppliedpromotions.addAll(accessPromotion); 
        }
        else{
            stackability = false;              
        }       
        rateCardPromotion.clear();
        rateCardPromotion = promotionSorter(rateCardPromotionMapWithRank);
        
        for(String prm : rateCardPromotion){
            Wireline_Promotion_Rules__c wpr = wprMap.get(prm.split('_')[0]);
            if ( wpr != null){
                if (!wpr.Stackable__c && !stackability){
                    toBeAppliedpromotions.add(prm);
                    stackability = true;
                } 
            }
        }
        
        if(!stackability){
            toBeAppliedpromotions.addAll(rateCardPromotion);               
        }
        else{
            stackability = false;              
        }       
        featurePromotion.clear();
        featurePromotion = promotionSorter(featurePromotionMapWithRank);
        
        for(String prm : featurePromotion){
            Wireline_Promotion_Rules__c wpr = wprMap.get(prm.split('_')[0]);
            System.debug('looking into feature promotion with id: ' + prm);
            System.debug('for the feature promotion stacable is: ' + wpr.Stackable__c);
            if(wpr != null){
                if(!wpr.Stackable__c && !stackability){
                    toBeAppliedpromotions.add(prm);
                    stackability = true;
                } 
            }
        }
        
        if(!stackability){
            toBeAppliedpromotions.addAll(featurePromotion);               
        }
        else{
            stackability = false;              
        }
        spPromotion.clear();
        spPromotion = promotionSorter(spPromotionMapWithRank);
        
        for (String prm : spPromotion){
            Wireline_Promotion_Rules__c wpr = wprMap.get(prm.split('_')[0]);
            if(wpr != null){
                if(!wpr.Stackable__c && !stackability){
                    toBeAppliedpromotions.add(prm);
                    stackability = true;
                } 
            }
        }
        if (!stackability){
            toBeAppliedpromotions.addAll(spPromotion);               
        }
        else{
            stackability = false;              
        }      
        orderPromotion.clear();
        orderPromotion = promotionSorter(orderPromotionMapWithRank);
        
        for(String prm : orderPromotion){
            Wireline_Promotion_Rules__c wpr = wprMap.get(prm.split('_')[0]);
            if(wpr != null){
                if(!wpr.Stackable__c && !stackability){
                    toBeAppliedpromotions.add(prm);
                    stackability = true;
                } 
            }
        }
        if(!stackability){
            toBeAppliedpromotions.addAll(orderPromotion);               
        }
        else{
            stackability = false;              
        }
        dealRegPromotion.clear();
        dealRegPromotion = promotionSorter(dealRegPromotionMapWithRank);
        
        for(String prm : dealRegPromotion){
            Wireline_Promotion_Rules__c wpr = wprMap.get(prm.split('_')[0]);
            if ( wpr != null){
                if (!wpr.Stackable__c && !stackability){
                    toBeAppliedpromotions.add(prm);
                    stackability = true;
                } 
            }
        }
        if (!stackability){
            toBeAppliedpromotions.addAll(dealRegPromotion);               
        }
        else{
            stackability = false;              
        }
        system.debug('@@@toBeAppliedpromotions: '+toBeAppliedpromotions);
        return toBeAppliedpromotions;
    }
     
    public List<String> determineAppliedPromotions(Map<String,integer> promotionsMap,boolean isMBC,boolean isPlus,Map<Id,Wireline_Promotion_Rules__c> wprMap){
        System.debug('look for me: is order MBC: ' + isMBC);
        System.debug('look for me: is order Plus: ' + isPlus);
        List<String> appliedPromotionsList = new List<String>();
        Set<String> promotionsSet = promotionsMap.keySet();
        
        for(String promo : promotionsSet){
            boolean isPromotionMBC = false;
            boolean isPromotionPlus = false;
            Wireline_Promotion_Rules__c wpr = wprMap.get(promo.split('_')[0]);
            appliedPromotionsNames.add(wpr.Name +'-'+ wpr.Promo_Type__c);
            system.debug('@@@appliedpromotionnames'+appliedPromotionsNames);
            System.debug('look for me promo id in determine applied promotions: '+ promo.split('_')[0]);
            Decimal configuredFields =wpr.Configured_Fields_Number__c;
            Decimal configuredAfterFields = wpr.Configured_Fields_After__c;  
            System.debug('configuredAfterFields : ' + configuredAfterFields );
            System.debug('promotionsMap.get(promo): ' + promotionsMap.get(promo));
            if (wpr.Field_Inputs__c.containsIgnoreCase('hi-cap'))
                isPromotionMBC = true;
            if (wpr.Field_Inputs__c.containsIgnoreCase('Plus'))
                 isPromotionPlus = true;
            System.debug('look for me: is Promotion MBC: ' + isPromotionMBC);
            System.debug('look for me: is Promotion Plus: ' + isPromotionPlus);
            if(isMBC && promo.split('_')[1].equalsIgnoreCase('Port')){
                if (!isPromotionMBC){
                    continue;
                }
            }
            if(isPlus && promo.split('_')[1].equalsIgnoreCase('Port')){
                if(!isPromotionPlus)
                    continue;
            }
            System.debug('Checking for after fields matches for promo id: ' + promo);
            system.debug('@@@configuredAfterFields: '+configuredAfterFields);
            if(promotionsMap.get(promo) >= configuredAfterFields){
                appliedPromotionsList.add(promo);
            }           
        }
        system.debug('@@@appliedPromotionsList: '+appliedPromotionsList);
        return appliedPromotionsList;
    }
      
    public List<String> takeOnlyAlreadyQuailifiedPromotions(List<String> afterPromoList,String quailedPromotions){
        List<String> promoFiltered = new List<String>();
        for (String ap: afterPromoList){
            if(String.isNotBlank(quailedPromotions) && quailedPromotions.contains(ap))
                promoFiltered.add(ap);
        }
        system.debug('@@@promoFiltered: '+promoFiltered);
        return promoFiltered;
    }
      
    public void appliedPromotionsCalcuationList(String quoteId,List<Id> siteIdLst, List<Id> avIdLst){
        system.debug('---siteIdLst---'+siteIdLst+'---quoteId---'+quoteId+'---avIdLst---'+avIdLst);
        map<String,String> bulkPromoMap = new map<String,String>();
        System.debug('@@@bulkPromotionList' + bulkPromotionList);
            
        if(bulkPromotionList !=null && bulkPromotionList.size() > 0){
            for(Wireline_Promotion_Rules__c promo : bulkPromotionList){
                bulkPromoMap.put(promo.Id,promo.Bulk_Criteria_Field_Value__c);
            }
        }
        Map<Id,Wireline_Promotion_Rules__c> wprMap = Promotion.getAll();
        Map<Id,AT_T_Customer_Site_Quote__c> siteToJunctionMap = new Map<Id,AT_T_Customer_Site_Quote__c>();
        
        List<AT_T_Customer_Site_Quote__c> finalJncSiteQuote = [SELECT Id,AT_T_Customer_Site__c,IGLOO_Supplier_Name__c,Wireline_Promotion_Id_Applied__c,Wireline_Promotion_Id_Sorted__c,AT_T_Quote__r.Apttus_Proposal__Opportunity__c,AT_T_Quote__r.Apttus_Proposal__Opportunity__r.Deal_Reg_Approved__c,AT_T_Quote__r.Apttus_Proposal__Opportunity__r.StageName, Wireline_Promotion_Number_Applied__c,Wireline_Promotion_Number_Applied_Old__c,Wireline_Promotion_Name_Applied_Old__c,Wireline_Promotion_Name_Applied__c FROM AT_T_Customer_Site_Quote__c WHERE AT_T_Quote__c =: quoteId and AT_T_Customer_Site__c IN: siteIdLst];
        
        Map<String,Set<String>> metaData = (Map<String,Set<String>>)Cache.Org.get(PromotionMetaData.class,'ALLMETADATA');
        String metaFields=String.join(new List<String>(metaData.get('Apttus_Config2__ProductAttributeValue__c')),',');
        system.debug('@@@metaFields----'+metaFields); 
        String avQuery='select AT_T_Customer_Site__c,'+metaFields+' from Apttus_Config2__ProductAttributeValue__c WHERE id IN:avIdLst';
        System.debug('av query: ' + avQuery);
        List<Apttus_Config2__ProductAttributeValue__c> av=database.query(avQuery); 
        system.debug('av '+av);
        for ( AT_T_Customer_Site_Quote__c sq: finalJncSiteQuote){
            siteToJunctionMap.put(sq.AT_T_Customer_Site__c,sq);
        }
        system.debug('@@@finalJncSiteQuote:'+finalJncSiteQuote);
        List<AT_T_Customer_Site_Quote__c> junctionListToBeUpdated = new List<AT_T_Customer_Site_Quote__c>();
        System.debug('========== Heap Size :: ' + Limits.getHeapSize());
        for(Apttus_Config2__ProductAttributeValue__c avr : av){
            
            AT_T_Customer_Site_Quote__c siteQ = siteToJunctionMap.get(avr.AT_T_Customer_Site__c);
            system.debug('---av---'+avr+'---siteQ---'+siteQ);
            if(avr != null && siteQ != null){
                junctionListToBeUpdated.add(appliedPromotionsCalcuation(siteQ,avr,wprMap,bulkPromoMap));
            }            
        }    
        system.debug('---junctionListToBeUpdated---'+junctionListToBeUpdated);
        if(junctionListToBeUpdated != null && junctionListToBeUpdated.size() > 0){
            update junctionListToBeUpdated;
        }        
     }
     
     public AT_T_Customer_Site_Quote__c appliedPromotionsCalcuation(AT_T_Customer_Site_Quote__c site, Apttus_Config2__ProductAttributeValue__c av, Map<Id,Wireline_Promotion_Rules__c> wprMap, Map<String,String> bulkPromoMap){
        boolean isMBC = false; 
        boolean isPlus = false;
        try{ 
            if(site!= Null && av!= Null){
                CachePromotionValueFetcher cpvf = new CachePromotionValueFetcher();
                Map<String,integer> quailiedPromotionsWithMatches = new Map<String,integer>();
                List<String> appliedPromotionsList = new List<String>();
                List<String> afterPromoList = new List<String>();
                system.debug('av '+av);
                String iglooSupplierName = '';
                if(String.isNotBlank(av.IGLOO_Supplier_Name__c) && av.IGLOO_Supplier_Name__c.contains(',')){
                    iglooSupplierName = av.IGLOO_Supplier_Name__c;
                    av.IGLOO_Supplier_Name__c = av.IGLOO_Supplier_Name__c.replaceAll(',','');
                }
                String avStr = String.valueOf(av).subStringAfter('{');
                avStr = avStr.remove('}');
                 if(String.isNotBlank(iglooSupplierName)){
                    avStr = avStr.replaceAll(iglooSupplierName,av.IGLOO_Supplier_Name__c);
                }
                List<String> avValue = avStr.split(',');
                System.debug('look for me av string value is: ' + avValue);
                
                list<Wireline_Promotion_Rules__c> accessBulkPromotionList = new list<Wireline_Promotion_Rules__c>();
                String nonBulkPromoString = ''; 
                if(String.isNotBlank(site.Wireline_Promotion_Id_Sorted__c)){
                    system.debug('@@@Wireline Sorted Promotions: '+site.Wireline_Promotion_Id_Sorted__c);
                    list<String> sortedPromoList = new list<String>();
                    list<String> filteredSortedPromoList = new list<String>();
                    sortedPromoList = site.Wireline_Promotion_Id_Sorted__c.split(',');
                    for(String str: sortedPromoList){
                        if(wprMap.get(Id.valueOf(str.split('_')[0])).Bulk_Promotion__c == true && wprMap.get(Id.valueOf(str.split('_')[0])).Promo_Type__c == 'Access'){
                            accessBulkPromotionList.add(wprMap.get(Id.valueOf(str.split('_')[0])));
                        }else{
                            filteredSortedPromoList.add(str);
                        }
                    }  
                    if(filteredSortedPromoList.size()>0){
                        nonBulkPromoString = String.join(filteredSortedPromoList,',');
                    }                                      
                }
                system.debug('@@@accessBulkPromotionList: '+accessBulkPromotionList);
                for(integer i =0;i<avValue.size();i++){
                    String avalue ='';
                    System.debug('av field: ' + avValue[i].split('=')[0].trim()+ ' avValue: '+ avValue[i].split('=')[1]);
                    if((avValue[i].split('=')[0]).trim().equals('Alternate_Access_Building_CLLI__c')){
                        avalue = avValue[i].split('=')[1]+'$BClli';
                    }else if ((avValue[i].split('=')[0]).trim().equals('Pricing_Tier__c')){
                        avalue = avValue[i].split('=')[1]+'$PTier';
                    }else if ((avValue[i].split('=')[0]).trim().equals('Qualification_Tier__c')){
                        avalue = avValue[i].split('=')[1]+'$QTier';
                    }else if ((avValue[i].split('=')[0]).trim().equals('Core_Based_Statistical_Area_Code__c')){
                        avalue = avValue[i].split('=')[1]+'$CBSA';
                    }else if ((avValue[i].split('=')[0]).trim().equals('Access_Speed_Generic__c')){
                        System.debug('found access speeed so appending acc to it');
                        avalue =avValue[i].split('=')[1]+'$ACC';
                    }   
                    else{ 
                        avalue = avValue[i].split('=')[1];
                    }
                    if(avValue[i].split('=')[0].trim().equals('Managed_Router__c') && avalue.trim().equals('true')){
                        avalue ='plus';
                        isPlus = true;
                    }
                    
                    if(avValue[i].split('=')[0].trim().equals('Unmanaged_Router__c') && avalue.trim().equals('true')){
                        avalue ='BASIC';
                    }
                    
                    if(avValue[i].split('=')[0].trim().equals('AT_T_IP_Flexible_Reach__c') && avalue.trim().equals('true')){
                        avalue='IPFLEX';
                    }
                    if(avValue[i].split('=')[0].trim().equals('Hi_Cap_Flex__c') && avalue.trim().equals('true')){
                        avalue='Hi-Cap';
                        isMBC = true;
                    }
                    if(avValue[i].split('=')[0].trim().equals('VLANs_Logical_Channels__c') && avalue.trim().equals('true')){
                        avalue='VLAN';
                    }
                    if(avValue[i].split('=')[0].trim().equals('CoS__c') && avalue.trim().equals('true')){
                        avalue='CoS';
                    }
                    if(avValue[i].split('=')[0].trim().equals('Additional_DNS__c') && avalue.trim().equals('Secondary')){
                        avalue='Secondary';
                    }
                    if(avValue[i].split('=')[0].trim().equals('IGLOO_Supplier_Name__c') && av.IGLOO_Supplier_Name__c != Null){
                        avalue = av.IGLOO_Supplier_Name__c+'$IGLSN';
                    }
                    if(avValue[i].split('=')[0].trim().equals('Igloo_Supplier_Name_Contains__c') && av.Igloo_Supplier_Name_Contains__c!= Null){
                        Set<String> iglooLecSet = new Set<String>();
                        for(String str : av.Igloo_Supplier_Name_Contains__c.split(' ')){
                            if(!iglooLecSet.contains(str+'$IGLSNC')){
                                iglooLecSet.add(str+'$IGLSNC');
                                avalue = str+'$IGLSNC';
                                system.debug('---avalue ---'+avalue +'---avValue---'+avValue[i].split('=')[0].trim());
                                List<String> qp = ((List<String>)cpvf.get(avalue));               
                                System.debug('qp: ' + qp); 
                      
                                if(qp != null){
                                    List<String> afterPromoListFiltered = takeOnlyAlreadyQuailifiedPromotions(qp, site.Wireline_Promotion_Id_Sorted__c); 
                                    if(afterPromoListFiltered!=null)
                                        afterPromoList.addAll(afterPromoListFiltered); 
                                }
                            }
                        }
                    }else{
                        system.debug('---avalue ---'+avalue +'---avValue---'+avValue[i].split('=')[0].trim());
                        List<String> qp = ((List<String>)cpvf.get(avalue));               
                        System.debug('qp: ' + qp); 
                        
                        if(qp != null){
                          List<String> afterPromoListFiltered = takeOnlyAlreadyQuailifiedPromotions(qp, site.Wireline_Promotion_Id_Sorted__c); 
                          if(afterPromoListFiltered!=null)
                            afterPromoList.addAll(afterPromoListFiltered); 
                        }
                    }
                }
                quailiedPromotionsWithMatches=qualifiyPromotions(afterPromoList);
                System.debug('quailiedPromotionsWithMatches: ' + quailiedPromotionsWithMatches);
                
                appliedPromotionsList= determineAppliedPromotions(quailiedPromotionsWithMatches,isMBC,isPlus,wprMap);
                system.debug('@@@Applied Promotion List: ' + appliedPromotionsList);                
                
                list<String> finalAppliedPromotionList = determineFinalPromotionsToBeApplied(appliedPromotionsList,accessBulkPromotionList,av,bulkPromoMap);   
                System.debug('@@@Final Applied Promotion List: ' + finalAppliedPromotionList);        
                
                List<String> appliedPrmsLst = determineStackablity(finalAppliedPromotionList,wprMap);
                list<string> wprIdAfter = new list<string>(); 
                if(appliedPrmsLst != null){
                    wprIdAfter.addAll(appliedPrmsLst);
                }
                list<ID> wprId = new list<ID>();
                for(String s : wprIdAfter){
                    wprId.add(s.split('_')[0]);
                }
                list<string> wprNameList = new list<string>();
                list<string> wprNumberList = new list<string>();
                
                for (Id wpromoId: wprId){
                    Wireline_Promotion_Rules__c wp = wprMap.get(String.valueOf(wpromoId));
                    if(wp.Promotion_Name__c !=null && wp.Promo_Type__c !=null){
                        wprNameList.add(wp.Promotion_Name__c + '_' + wp.Promo_Type__c);
                        wprNumberList.add(wp.Name + '_' + wp.Promo_Type__c);
                    }
                }
                system.debug('@@@wprNameList: '+wprNameList);
                system.debug('@@@wprNumberList: '+wprNumberList);
                
                if(site.Wireline_Promotion_Id_Applied__c != Null && site.Wireline_Promotion_Id_Applied__c != String.join(appliedPrmsLst,',')){
                    site.Wireline_Promotion_Id_Applied_Old__c = site.Wireline_Promotion_Id_Applied__c;
                    site.Wireline_Promotion_Name_Applied_Old__c = site.Wireline_Promotion_Name_Applied__c;
                    site.Wireline_Promotion_Number_Applied_Old__c = site.Wireline_Promotion_Number_Applied__c;
                }
                site.Wireline_Promotion_Id_Applied__c = String.join(appliedPrmsLst,',');
                site.Wireline_Promotion_Name_Applied__c = String.join(wprNameList,',');
                site.Wireline_Promotion_Number_Applied__c = String.join(wprNumberList,',');
                return site;
            }
            else{
                return null;
            }
        }catch(Exception e){
            system.debug('Exception Caught in appliedPromotionsCalcuation method of PromotionQualifierUtil class at Line: '+e.getLineNumber()+' Message: '+e.getMessage());
            return null;
        }       
    }
    
    /*Method used to determine promotions at site level*/
    public void determinePromotionAtSiteLevel(String siteId,String quoteId){
        system.debug('@@@Inside determinePromotionAtSiteLevel');
        List<String> qualifiedPromotionsQuoteandAccount = new List<String>();
        Date promoSimulationDate;
        Boolean testAccount = false;
        String productCode, productTerm, accountName, spAccountTier, dpeTrialAccount, saoFlag;
        Apttus_Proposal__Proposal__c quote = new Apttus_Proposal__Proposal__c();
        Account account = new Account();
        List<AT_T_Customer_Site_Quote__c> customerSiteQuote = new List<AT_T_Customer_Site_Quote__c>(); 
        list<Wireline_Promotion_Rules__c> eligibleBulkPromotionList = new list<Wireline_Promotion_Rules__c>(); 
      
        CachePromotionValueFetcher cpvf = new CachePromotionValueFetcher();
        try{ 
            List<WirelinPromoObjectAttributes__c> attributeList = WirelinPromoObjectAttributes__c.getall().values();
            List<String> beforeObjectsNameList=new List<String>();
            for(WirelinPromoObjectAttributes__c attribute : attributeList){
               beforeObjectsNameList.add(attribute.value__c);
            } 
            system.debug('@@@beforeObjectsNameList: '+beforeObjectsNameList);
            Map<String,Set<String>> metaData = (Map<String,Set<String>>)Cache.Org.get(PromotionMetaData.class,'ALLMETADATA');
            System.debug('Meta Data: ' + metaData);
            
            System.debug(metaData.get('Apttus_Proposal__Proposal__c'));
            String metaFields=String.join(new List<String>(metaData.get('Apttus_Proposal__Proposal__c')),',');
            System.debug(metaFields);
            system.debug('@@@metaFields: '+metaFields);
                 
            String quoteQuery='select id, Apttus_Proposal__Account__r.id,Promotion_Simulation_Date__c,Apttus_Proposal__Account__r.Test_Company__c,'+metaFields+' from Apttus_Proposal__Proposal__c WHERE id =:quoteId Limit 1';
            System.debug('Quote query: ' + quoteQuery);
            quote=database.query(quoteQuery); 
            system.debug('currentQuote '+quote);
            productCode = quote.ProdCode__c;            
            productTerm = quote.Apttus_Proposal__Payment_Term__c;
            
            String quoteStr = String.valueOf(quote).subStringAfter('{');
            quoteStr = quoteStr.remove('}');
            System.debug('quoteStr: '+ quoteStr); 
            List<String> quoteValue = quoteStr.split(',');

            for(integer i =2;i<quoteValue.size();i++){                
                if(quoteValue[i].split('=')[0].trim() != 'NumberofSites__c'){
                    System.debug('quote field: ' + quoteValue[i].split('=')[0]+ '  '+ quoteValue[i].split('=')[1]);
                    list<String> qp = new list<String>();
                    qp = (List<String>)cpvf.get(quoteValue[i].split('=')[1]);
                    if(qp!= null && qp.size()>0)
                        qualifiedPromotionsQuoteandAccount.addall(qp);
                }
            }
            
            String AccmetaFields = String.join(new List<String>(metaData.get('Account')),',');
            System.debug('Account fields are: '+AccmetaFields);
            Id accountId = quote.Apttus_Proposal__Account__r.id;
            Id quoteObj = quote.id;
            promoSimulationDate = quote.Promotion_Simulation_Date__c;
            testAccount = quote.Apttus_Proposal__Account__r.Test_Company__c;  
            
            String accountQuery = 'select '+AccmetaFields+' from Account WHERE id =:accountId Limit 1';
            account = database.query(accountQuery);        
            if(account.Name.contains(',')){
                account.Name = account.Name.replaceAll(',','');
            }
            accountName = account.Name;
            system.debug('@@@accountName: '+accountName);
            spAccountTier = account.SP_Tier__c;
            dpeTrialAccount = account.DPE_Trial_Formula__c;
            saoFlag = account.SAO_Formula__c; 
            
            String accountStr = String.valueOf(account).subStringAfter('{');
            accountStr = accountStr.remove('}');
            System.debug('accountStr: '+ accountStr); 
            List<String> accountValue = accountStr.split(',');
            
            for(integer i =0;i<accountValue.size();i++){
                List<String> qp = (List<String>)cpvf.get(accountValue[i].split('=')[1]);
                if (qp!=null)
                    qualifiedPromotionsQuoteandAccount.addall(qp);
            }
            system.debug('@@@qualifiedPromotionsQuoteandAccount: '+qualifiedPromotionsQuoteandAccount);
                  
            String sitemetaFields=String.join(new List<String>(metaData.get('CustomerSite__c')),',');
            system.debug('---site id---'+siteId);
            String siteQuery = 'select AT_T_Quote__r.Apttus_Proposal__Opportunity__c,AT_T_Quote__r.Apttus_Proposal__Opportunity__r.Deal_Reg_Approved__c,AT_T_Quote__r.Apttus_Proposal__Opportunity__r.StageName,Wireline_Promotion_Id_Sorted__c,Wireline_Promotion_Id_Before__c,Wireline_Promotion_Id_After__c, ' + sitemetaFields + ' from AT_T_Customer_Site_Quote__c where AT_T_Customer_Site__c =:siteId AND AT_T_Quote__c =:quoteId'; 
            System.debug('site query: ' + siteQuery);
            customerSiteQuote = database.query(siteQuery); 
            System.debug('Customer sites: ' + customerSiteQuote.size());
            
            List<AT_T_Customer_Site_Quote__c> junctionsToBeUpdated = new List<AT_T_Customer_Site_Quote__c>();
            
            bulkPromotionList = new list<Wireline_Promotion_Rules__c>();   
            if(promoSimulationDate == null){
                if(testAccount == false){
                    bulkPromotionList = [SELECT id,name,Field_Inputs__c,Active__c,Promotion_Certified__c,Do_Not_Run__c,Expired__c,Bulk_Promotion__c,Bulk_Criteria_Field_Name__c,Bulk_Criteria_Field_Value__c FROM Wireline_Promotion_Rules__c WHERE Promo_Type__c = 'Access' AND Active__c = TRUE AND Do_Not_Run__c = FALSE AND Expired__c = FALSE AND Promotion_Certified__c = TRUE AND For_Testing__c = FALSE AND Bulk_Promotion__c = TRUE];
                    system.debug('@@@Inside 1: '+bulkPromotionList);
                }else{
                    bulkPromotionList = [SELECT id,name,Field_Inputs__c,Active__c,Promotion_Certified__c,Do_Not_Run__c,Expired__c,Bulk_Promotion__c,Bulk_Criteria_Field_Name__c,Bulk_Criteria_Field_Value__c FROM Wireline_Promotion_Rules__c WHERE Promo_Type__c = 'Access' AND Active__c = TRUE AND Do_Not_Run__c = FALSE AND Expired__c = FALSE AND Bulk_Promotion__c = TRUE];
                    system.debug('@@@Inside 2: '+bulkPromotionList);
                }
            }
            else{
                if(testAccount == false){
                    bulkPromotionList = [SELECT id,name,Field_Inputs__c,Start_Date__c,End_Date__c,Active__c,For_Testing__c,Promotion_Certified__c,Do_Not_Run__c,Expired__c,Bulk_Promotion__c,Bulk_Criteria_Field_Name__c,Bulk_Criteria_Field_Value__c FROM Wireline_Promotion_Rules__c WHERE Promo_Type__c = 'Access' AND Start_Date__c <= :promoSimulationDate AND End_Date__c >= :promoSimulationDate AND Do_Not_Run__c = FALSE AND Expired__c = FALSE AND For_Testing__c = FALSE AND Bulk_Promotion__c = TRUE];
                    system.debug('@@@Inside 3: '+bulkPromotionList);
                }else{
                    bulkPromotionList = [SELECT id,name,Field_Inputs__c,Start_Date__c,End_Date__c,Active__c,For_Testing__c,Promotion_Certified__c,Do_Not_Run__c,Expired__c,Bulk_Promotion__c,Bulk_Criteria_Field_Name__c,Bulk_Criteria_Field_Value__c FROM Wireline_Promotion_Rules__c WHERE Promo_Type__c = 'Access' AND Start_Date__c <= :promoSimulationDate AND End_Date__c >= :promoSimulationDate AND Do_Not_Run__c = FALSE AND Expired__c = FALSE AND Bulk_Promotion__c = TRUE];
                    system.debug('@@@Inside 4: '+bulkPromotionList);
                }
            }            
            system.debug('@@@Bulk Promotion List: '+ bulkPromotionList);  
            system.debug('@@@Bulk Promotion Size: '+ bulkPromotionList.size());          
            
            for(Wireline_Promotion_Rules__c wprRule : bulkPromotionList){
                if(wprRule.Field_Inputs__c != null){
                    String fieldInputs = wprRule.Field_Inputs__c.replaceAll('"','');
                    Boolean bulkPromotionEligible = true;
                    for(String sectionNameAndValue : fieldInputs.split('\\|')){
                        system.debug('@@@Promo Id: '+ wprRule.Id+' @@@Map: '+sectionNameAndValue);
                        if(sectionNameAndValue.split(':')[0] == 'Product' && sectionNameAndValue.split(':').size() > 1){
                            if(sectionNameAndValue.split(':')[1] != null && sectionNameAndValue.split(':')[1] != '' && !sectionNameAndValue.split(':')[1].split(';').contains(productCode)){
                                bulkPromotionEligible = false;
                                system.debug('@@@Product Not Eligible!!!');
                                break;
                            }
                        }    
                        if(sectionNameAndValue.split(':')[0] == 'SP Tier' && sectionNameAndValue.split(':').size() > 1){
                            if(sectionNameAndValue.split(':')[1] != null && sectionNameAndValue.split(':')[1] != '' && !sectionNameAndValue.split(':')[1].split(';').contains(spAccountTier)){
                                bulkPromotionEligible = false;
                                system.debug('@@@SP Tier Not Eligible!!!');
                                break;
                            }
                        }
                        if(sectionNameAndValue.split(':')[0] == 'Term' && sectionNameAndValue.split(':').size() > 1){
                            if(sectionNameAndValue.split(':')[1] != null && sectionNameAndValue.split(':')[1] != '' && !sectionNameAndValue.split(':')[1].split(';').contains(productTerm)){
                                bulkPromotionEligible = false;
                                system.debug('@@@Term Not Eligible!!!');
                                break;
                            }
                        }
                        if(sectionNameAndValue.split(':')[0] == 'Site Quote Type' && sectionNameAndValue.split(':').size() > 1 && customerSiteQuote.size()> 0 && String.isNotBlank(customerSiteQuote[0].Portal_Site_Formula__c)){
                            if(sectionNameAndValue.split(':')[1] != null && sectionNameAndValue.split(':')[1] != '' && customerSiteQuote[0].Portal_Site_Formula__c == 'Portal' && !sectionNameAndValue.split(':')[1].split(';').contains(customerSiteQuote[0].Portal_Site_Formula__c)){
                                bulkPromotionEligible = false;
                                system.debug('@@@Portal Type Not Eligible!!!');
                                break;
                            }                        
                        }
                        if(sectionNameAndValue.split(':')[0] == 'Site Quote Type' && sectionNameAndValue.split(':').size() > 1 && customerSiteQuote.size()> 0 && String.isNotBlank(customerSiteQuote[0].API_IPQ_Site_Formula__c)){
                            if(sectionNameAndValue.split(':')[1] != null && sectionNameAndValue.split(':')[1] != '' && customerSiteQuote[0].API_IPQ_Site_Formula__c == 'API' && !sectionNameAndValue.split(':')[1].split(';').contains(customerSiteQuote[0].API_IPQ_Site_Formula__c)){
                                bulkPromotionEligible = false;
                                system.debug('@@@API Type Not Eligible!!!');  
                                break;      
                            }
                        }    
                        if(sectionNameAndValue.split(':')[0] == 'SP List' && sectionNameAndValue.split(':').size() > 1){
                            if(sectionNameAndValue.split(':')[1] != null && sectionNameAndValue.split(':')[1] != '' && !sectionNameAndValue.split(':')[1].replaceAll(',','').split(';').contains(accountName)){
                                bulkPromotionEligible = false;
                                system.debug('@@@Account Not Eligible!!!');
                                break;
                            }
                        }
                        if(sectionNameAndValue.split(':')[0] == 'DPE Trial' && sectionNameAndValue.split(':').size() > 1){
                            if(sectionNameAndValue.split(':')[1] != null && sectionNameAndValue.split(':')[1] != '' && sectionNameAndValue.split(':')[1] == 'DPE Trial' && dpeTrialAccount != 'DPE Trial'){
                                bulkPromotionEligible = false;
                                system.debug('@@@DPE Trial Account Type Not Eligible!!!');
                                break;
                            }
                        }
                        if(sectionNameAndValue.split(':')[0] == 'SAO' && sectionNameAndValue.split(':').size() > 1){
                            if(sectionNameAndValue.split(':')[1] != null && sectionNameAndValue.split(':')[1] != '' && ((saoFlag == 'SAO' && !sectionNameAndValue.split(':')[1].split(';').contains('SAO')) || (saoFlag != 'SAO' && !sectionNameAndValue.split(':')[1].split(';').contains('Non SAO')))){
                                bulkPromotionEligible = false;
                                system.debug('@@@SAO Account Type Not Eligible!!!');
                                break;
                            }
                        }
                    }
                    if(bulkPromotionEligible == true){
                        system.debug('@@@Bulk Promotion Eligible!!!');
                        eligibleBulkPromotionList.add(wprRule);
                    }
                }                
            }
            system.debug('@@@eligibleBulkPromotionList: '+eligibleBulkPromotionList);
            
            //Logic End
            for(AT_T_Customer_Site_Quote__c csq : customerSiteQuote){
                List<String> qPromotionsQuoteandAccount = new List<String>();  
                List<String> qPromotions = new List<String>();
                Map<String,integer> quailiedPromotionsWithMatches = new Map<String,integer>();
                String siteStr = String.valueOf(csq).subStringAfter('{');
                siteStr = siteStr.remove('}');
                List<String> siteValue = siteStr.split(',');
                for(integer i =0;i<siteValue.size();i++){
                    System.debug('site Value is: ' + siteValue);        
                    List<String> qp = new List<String>();
                    if(siteValue[i].split('=').size() <=1){
                        System.debug('Site value is not good for split: ' + siteValue);                  
                        continue; 
                    }
                    System.debug('site field: ' + siteValue[i].split('=')[0]+ ' siteValue: '+ siteValue[i].split('=')[1]);
                    if((siteValue[i].split('=')[0]).trim().equals('Alternate_Access_Building_CLLI__c')){
                        qp = (List<String>)cpvf.get(siteValue[i].split('=')[1]+'$BClli');
                    }else if ((siteValue[i].split('=')[0]).trim().equals('Pricing_Tier__c')){
                        qp = (List<String>)cpvf.get(siteValue[i].split('=')[1]+'$PTier');
                    }else if ((siteValue[i].split('=')[0]).trim().equals('Qualification_Tier__c')){
                        qp = (List<String>)cpvf.get(siteValue[i].split('=')[1]+'$QTier');
                    }else if ((siteValue[i].split('=')[0]).trim().equals('Core_Based_Statistical_Area_Code__c')){
                        qp = (List<String>)cpvf.get(siteValue[i].split('=')[1]+'$CBSA');
                    }else if ((siteValue[i].split('=')[0]).trim().equals('Access_Speed_Generic__c')){
                        qp = (List<String>)cpvf.get(siteValue[i].split('=')[1]+'$ACC');
                    }else if((siteValue[i].split('=')[0]).trim().equals('Alternate_Access_vendorName__c')){
                        system.debug('@@@ITPA LEC: '+siteValue[i]);
                        qp = (List<String>)cpvf.get(siteValue[i].split('=')[1]+'$ITPA');
                    }else if((siteValue[i].split('=')[0]).trim().equals('ITPA_LEC_Contains__c')){
                        system.debug('@@@ITPA LEC Contains: '+siteValue[i]);
                        set<String> itpaLECSet = new set<String>();
                        for(String str : siteValue[i].split('=')[1].split(' ')){                                                       
                            if((List<String>)cpvf.get(str+'$ITPAC') != null){                                
                                if(!itpaLECSet.contains(str+'$ITPAC')){
                                    system.debug('@@@ITPA LEC Contains String: '+str); 
                                    itpaLECSet.add(str+'$ITPAC');
                                    qp.addAll((List<String>)cpvf.get(str+'$ITPAC'));
                                }
                            }
                        }
                    }else if((siteValue[i].split('=')[0]).trim().equals('VASA_LEC__c')){
                        system.debug('@@@VASA LEC Contains: '+siteValue[i]);
                        qp = (List<String>)cpvf.get(siteValue[i].split('=')[1]+'$VASA');
                    }else if((siteValue[i].split('=')[0]).trim().equals('Original_VASA_LEC_Contains__c')){
                        set<String> vasaLECSet = new set<String>();
                        for(String str : siteValue[i].split('=')[1].split(' ')){
                            if((List<String>)cpvf.get(str+'$VASAC') != Null){
                                if(!vasaLECSet.contains(str+'$VASAC')){
                                    system.debug('@@@VASA LEC Contains String: '+siteValue[i]);
                                    vasaLECSet.add(str+'$VASAC');
                                    qp.addAll((List<String>)cpvf.get(str+'$VASAC'));
                                }
                            }
                        }
                    }else{
                        qp = (List<String>)cpvf.get(siteValue[i].split('=')[1]);
                    }
                    System.debug('qp value is: ' + qp);
                    if(qp!=null){
                        qPromotions.addall(qp);
                    }
                }
                system.debug('@@@qPromotions: '+qPromotions);
                system.debug('@@@qPromotionsQuoteandAccount: '+qPromotionsQuoteandAccount);
                
                qPromotionsQuoteandAccount.addAll(qualifiedPromotionsQuoteandAccount);
                qPromotionsQuoteandAccount.addAll(qPromotions);
                quailiedPromotionsWithMatches = qualifiyPromotions(qPromotionsQuoteandAccount);
                system.debug('@@@quailiedPromotionsWithMatches: '+quailiedPromotionsWithMatches);
                Map<String,List<String>> bap = beforeandAfterPromotions(quailiedPromotionsWithMatches, promoSimulationDate, testAccount);
                system.debug('@@@bap: '+bap);
                
                Map<String,List<String>> finalPromoMap = determineBulkPromotionEligiblity(bap,account,quote,csq,eligibleBulkPromotionList);
                System.debug('@@@Sorted Promotions: '+promotionTypeBasedLists(finalPromoMap));
                List<String> sortedPromotions = promotionTypeBasedLists(finalPromoMap);              
                junctionsToBeUpdated.add(updateQuoteJunctionWithPromotions(bap,sortedPromotions,csq));
            }
            if(junctionsToBeUpdated.size() > 0){
                update junctionsToBeUpdated;
            }
        }
        catch(Exception e){
            system.debug('Exception in LookForNewPromotions method of PromotionQualifierUtil: '+e+' at line no '+e.getLineNumber()+ '  Message - >'+ e.getMessage());        
        }
    }   
     
    /*Method used to determine bulk promotion eligibility*/    
    public map<String,List<String>> determineBulkPromotionEligiblity(map<String,list<String>> bap, Account account, Apttus_Proposal__Proposal__c quote, AT_T_Customer_Site_Quote__c customerSiteQuote, list<Wireline_Promotion_Rules__c> eligibleBulkPromotionList){
        try{
            system.debug('@@@Non Bulk Promotions: '+bap);
            system.debug('@@@Customer Site Quote: '+customerSiteQuote);
            
            list<String> bulkPromotionStringList = new list<String>();
            for(Wireline_Promotion_Rules__c wprRule : eligibleBulkPromotionList){
                if(String.isNotBlank(wprRule.Bulk_Criteria_Field_Name__c) && String.isNotBlank(wprRule.Bulk_Criteria_Field_Value__c)){
                    list<String> criteriaFieldValueList = new list<String>();
                    criteriaFieldValueList = wprRule.Bulk_Criteria_Field_Value__c.replaceAll('[|,|.|\\,|\\-|"||:|~|!|@|#|$|%|^|&|*|_|+|=|<|>|?|\\(|\\)|\\{|\\}|\\\'"]', '').deleteWhitespace().touppercase().split(';');
                    system.debug('@@@Bulk Criteria Field Value List: '+criteriaFieldValueList);
                    if(criteriaFieldValueList.size() > 0){
                        String street = String.isNotBlank(customerSiteQuote.Address_Line__c) ? customerSiteQuote.Address_Line__c.replaceAll('[|,|.|\\,|\\-|"||:|~|!|@|#|$|%|^|&|*|_|+|=|<|>|?|\\(|\\)|\\{|\\}|\\\'"]', '').deleteWhitespace().touppercase() : '';
                        String city = String.isNotBlank(customerSiteQuote.City__c) ? customerSiteQuote.City__c.replaceAll('[|,|.|\\,|\\-|"||:|~|!|@|#|$|%|^|&|*|_|+|=|<|>|?|\\(|\\)|\\{|\\}|\\\'"]', '').deleteWhitespace().touppercase() : '';
                        String state = String.isNotBlank(customerSiteQuote.State__c) ? customerSiteQuote.State__c.replaceAll('[|,|.|\\,|\\-|"||:|~|!|@|#|$|%|^|&|*|_|+|=|<|>|?|\\(|\\)|\\{|\\}|\\\'"]', '').deleteWhitespace().touppercase() : '';
                        String zipCode = String.isNotBlank(customerSiteQuote.Zip_Code__c) ? customerSiteQuote.Zip_Code__c.replaceAll('[|,|.|\\,|\\-|"||:|~|!|@|#|$|%|^|&|*|_|+|=|<|>|?|\\(|\\)|\\{|\\}|\\\'"]', '').deleteWhitespace().touppercase() : '';
                        String buildingCLLI = String.isNotBlank(customerSiteQuote.Alternate_Access_Building_CLLI__c) ? customerSiteQuote.Alternate_Access_Building_CLLI__c.replaceAll('[|,|.|\\,|\\-|"||:|~|!|@|#|$|%|^|&|*|_|+|=|<|>|?|\\(|\\)|\\{|\\}|\\\'"]', '').deleteWhitespace().touppercase() : '';
                        String swcCLLI = String.isNotBlank(customerSiteQuote.Alternate_Access_servingWireCenter__c) ? customerSiteQuote.Alternate_Access_servingWireCenter__c.replaceAll('[|,|.|\\,|\\-|"||:|~|!|@|#|$|%|^|&|*|_|+|=|<|>|?|\\(|\\)|\\{|\\}|\\\'"]', '').deleteWhitespace().touppercase() : '';
                        String vasaLEC = String.isNotBlank(customerSiteQuote.VASA_LEC__c) ? customerSiteQuote.VASA_LEC__c.replaceAll('[|,|.|\\,|\\-|"||:|~|!|@|#|$|%|^|&|*|_|+|=|<|>|?|\\(|\\)|\\{|\\}|\\\'"]', '').deleteWhitespace().touppercase() : '';
                        String itpaLEC = String.isNotBlank(customerSiteQuote.Alternate_Access_vendorName__c) ? customerSiteQuote.Alternate_Access_vendorName__c.replaceAll('[|,|.|\\,|\\-|"||:|~|!|@|#|$|%|^|&|*|_|+|=|<|>|?|\\(|\\)|\\{|\\}|\\\'"]', '').deleteWhitespace().touppercase() : '';
                        String globalLocationId = String.isNotBlank(customerSiteQuote.Global_Location_ID__c) ? customerSiteQuote.Global_Location_ID__c.replaceAll('[|,|.|\\,|\\-|"||:|~|!|@|#|$|%|^|&|*|_|+|=|<|>|?|\\(|\\)|\\{|\\}|\\\'"]', '').deleteWhitespace().touppercase() : '';
                        String cbsaCode = String.isNotBlank(customerSiteQuote.Core_Based_Statistical_Area_Code__c) ? customerSiteQuote.Core_Based_Statistical_Area_Code__c.replaceAll('[|,|.|\\,|\\-|"||:|~|!|@|#|$|%|^|&|*|_|+|=|<|>|?|\\(|\\)|\\{|\\}|\\\'"]', '').deleteWhitespace().touppercase() : '';                       
                        
                        if((wprRule.Bulk_Criteria_Field_Name__c == 'Street' && String.isNotBlank(street) && criteriaFieldValueList.contains(street)) || 
                           (wprRule.Bulk_Criteria_Field_Name__c == 'City' && String.isNotBlank(city) && criteriaFieldValueList.contains(city)) || 
                           (wprRule.Bulk_Criteria_Field_Name__c == 'State' && String.isNotBlank(state) && criteriaFieldValueList.contains(state)) || 
                           (wprRule.Bulk_Criteria_Field_Name__c == 'Zip Code' && String.isNotBlank(zipCode) && criteriaFieldValueList.contains(zipCode)) ||
                           (wprRule.Bulk_Criteria_Field_Name__c == 'Building CLLI' && String.isNotBlank(buildingCLLI) && criteriaFieldValueList.contains(buildingCLLI)) ||
                           (wprRule.Bulk_Criteria_Field_Name__c == 'SWC CLLI' && String.isNotBlank(swcCLLI) && criteriaFieldValueList.contains(swcCLLI)) ||
                           (wprRule.Bulk_Criteria_Field_Name__c == 'VASA LEC' && String.isNotBlank(vasaLEC) && criteriaFieldValueList.contains(vasaLEC)) ||
                           (wprRule.Bulk_Criteria_Field_Name__c == 'ITPA LEC' && String.isNotBlank(itpaLEC) && criteriaFieldValueList.contains(itpaLEC)) ||
                           (wprRule.Bulk_Criteria_Field_Name__c == 'IGLOO LEC') ||
                           (wprRule.Bulk_Criteria_Field_Name__c == 'Global Location ID' && String.isNotBlank(globalLocationId) && criteriaFieldValueList.contains(globalLocationId)) ||
                           (wprRule.Bulk_Criteria_Field_Name__c == 'CBSA Code' && String.isNotBlank(cbsaCode) && criteriaFieldValueList.contains(cbsaCode))
                           ){
                            bulkPromotionStringList.add(wprRule.id+'_Access');
                            system.debug('@@@Bulk Promotion Qualified: '+wprRule.Id);
                        }
                    }
                }
            }
            
            if(bulkPromotionStringList.size()>0){        
                if(bap != null && bap.containsKey('after') && bap.get('after') != null){
                    system.debug('@@@inside if');
                    bap.get('after').addAll(bulkPromotionStringList);
                }else{
                    system.debug('@@@inside else');
                    bap.put('after',bulkPromotionStringList);
                }                
            }
            return bap;     
        }
        catch(Exception ex){
            system.debug('@@@Exception caught in determineBulkPromotionEligiblity method of PromotionQualifierUtil class: '+ex+' at line number: '+ex.getLineNumber());
            return bap;
        }
    }
    
    /*Method used to determine bulk promotion eligibility*/    
    public List<String> determineFinalPromotionsToBeApplied(List<String> appliedPromotionsList, list<Wireline_Promotion_Rules__c> accessBulkPromotionList, Apttus_Config2__ProductAttributeValue__c av, map<String,String> bulkPromoMap){
        try{
            system.debug('@@@appliedPromotionsList: '+appliedPromotionsList);
            system.debug('@@@accessBulkPromotionList: '+accessBulkPromotionList); 
            system.debug('@@@av: '+av);
            String accessSpeed = '';
            String iglooSupplierName = '';
            if(String.isNotBlank(av.Access_Speed_Generic__c)){
                accessSpeed = av.Access_Speed_Generic__c.replaceAll(' ','');
            }
            if(String.isNotBlank(av.IGLOO_Supplier_Name__c)){
                iglooSupplierName = av.IGLOO_Supplier_Name__c.replaceAll(' ', '');
            }
            system.debug('@@@access speed: '+accessSpeed);
            list<String> bulkPromotionStringList = new list<String>();
            for(Wireline_Promotion_Rules__c wprRule : accessBulkPromotionList){
                Boolean wirelinePromotionEligible = false;
                if(wprRule.Field_Inputs__c != null){
                    String fieldInputs = wprRule.Field_Inputs__c.replaceAll('"','');
                    for(String sectionNameAndValue : fieldInputs.split('\\|')){
                        system.debug('@@@Promo Id: '+ wprRule.Id+' @@@Map: '+sectionNameAndValue);
                        if(sectionNameAndValue.split(':')[0] == 'Access Speed' && sectionNameAndValue.split(':').size() > 1){                            
                            if(sectionNameAndValue.split(':')[1] != null && sectionNameAndValue.split(':')[1] != '' && sectionNameAndValue.split(':')[1].replaceAll(' ', '').split(';').contains(accessSpeed)){
                                wirelinePromotionEligible = true;
                                system.debug('@@@Access Speed Match!!! '+wprRule);
                            }
                        }
                    }
                }
                if(wprRule.Bulk_Criteria_Field_Name__c == 'IGLOO LEC' && bulkPromoMap.containsKey(wprRule.Id) && String.isNotBlank(bulkPromoMap.get(wprRule.Id))){
                    list<String> criteriaFieldValueList = new list<String>();
                    criteriaFieldValueList = bulkPromoMap.get(wprRule.Id).deleteWhitespace().split(';');
                    if(String.isBlank(iglooSupplierName) || (String.isNotBlank(iglooSupplierName) && !criteriaFieldValueList.contains(iglooSupplierName))){
                        wirelinePromotionEligible = false;
                        system.debug('@@@IGLOO Supplier Name MisMatch!!! '+wprRule);
                    }
                }
                if(wirelinePromotionEligible == true){
                    system.debug('@@@Bulk Promotion Eligible: '+wprRule);
                    bulkPromotionStringList.add(wprRule.Id+'_Access');
                }    
            }
            if(bulkPromotionStringList.size()>0){        
                appliedPromotionsList.addAll(bulkPromotionStringList);     
            }
            return appliedPromotionsList;
        }
        catch(Exception ex){
            system.debug('@@@Exception caught in determineFinalPromotionsToBeApplied method of PromotionQualifierUtil class: '+ex+' at line number: '+ex.getLineNumber());
            return appliedPromotionsList;
        }
    }
}