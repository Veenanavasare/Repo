/******************************************************************************************************************
Name:        PromotionCacheFeeder
Description: This is the helper class which reads the promotions configured and creates the data in the cache. 
             Map will be in this format: 
             <Value>:[<list of promotions>];
             To access the cache data do CachePromotionValueFetcher Object = new CachePromotionValueFetcher();
             Object.get(<value>);
             This will return the list of promotions for every value in all the configured Active promotions. 
Author:      Varun Kumar
Change Log:  10/23/2018     Initial Version 1        Varun Kumar
*******************************************************************************************************************/
public class PromotionCacheFeeder{

    List<Wireline_Promotion_Rules__c> wpr; 
    Set<String> cacheKeySet = new Set<String>(); 
    
    /*Use this constructor when you want to load a particular Promotion*/
    public PromotionCacheFeeder(string promotionid){
        wpr = [select id,Select_Fields_Json__c,Promo_Type__c,Field_Inputs__c from Wireline_Promotion_Rules__c where id =:promotionid AND Bulk_Promotion__c = FALSE];    
    }
    
    /*Use this constructor when you want to load all Promotion*/
    public PromotionCacheFeeder(){
        wpr = [select id,Select_Fields_Json__c,Promo_Type__c,Field_Inputs__c,Do_Not_Run__c,Expired__c from Wireline_Promotion_Rules__c Where Do_Not_Run__c = FALSE AND Expired__c = FALSE AND Bulk_Promotion__c = FALSE];
        System.debug('@@@PromotionCacheFeeder WPR Size: ' + wpr.size());
    }

    /*Call this method for loading the data into Cache. Constructor will only prepare the data to be loaded*/
    public void feedPromotions(){  
       
        WirelinePromoCacheData__c cacheData = [Select cacheKey__c,cacheValue__c from WirelinePromoCacheData__c  limit 1];
        try{
            for(Wireline_Promotion_Rules__c wp : wpr){
                system.debug('@@wprcustom' + wp.id);
                if(wp.Select_Fields_Json__c != null){
                    System.debug('JSON value is: ' + wp.Select_Fields_Json__c);
                    parseJsonforfieldValues(wp.id,wp.Select_Fields_Json__c);
                }
                String sp = wp.Field_Inputs__c;
                if(sp!=null && sp.containsIgnoreCase('SP List')){
                    List<String> ss = sp.split('\\|');
                    System.debug('@@@SP Account List: ' + ss);
                    for(String s : ss){
                        if(s.containsIgnoreCase('SP List')){
                            List<String> spnamesList = s.split(':');
                            System.debug('@@@SP Names After Split 1: '+spnamesList);
                            if(spnamesList.size() >= 2 && spnamesList[1] != null && spnamesList[1] != ''){
                                List<String> spnList = spnamesList[1].split(';');
                                system.debug('@@@SP Names After Split 2: '+spnList);
                                for(String spnl : spnList){
                                    system.debug('@@@SP Name Before Null Check: '+spnl);
                                    spnl = spnl.replaceAll('"', '');
                                    if(spnl != ''){
                                        system.debug('@@@SP Name in loop: '+spnl);
                                        new PromotionCacheBuilder(spnl,wp.Id+'_'+wp.Promo_Type__c); 
                                        spnl = spnl.deleteWhitespace();
                                        spnl= spnl.replaceAll('[|,|.|\\,|\\-|"||:|~|!|@|#|$|%|^|&|*|_|+|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]', '');
                                        spnl= spnl.toUpperCase();                                        
                                        cacheKeySet.add(spnl); 
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        catch(Exception e){ 
            system.debug('Exception '+e.getMessage()+' at line no '+e.getLineNumber());
        }
        cacheData.cacheKey__c = 'cacheKeys';
        cacheData.cacheValue__c =  (String)JSON.serialize(cacheKeySet);
        system.debug('Cachekeyset--->'+cacheKeySet);
        system.debug('-------->'+cacheData);
        update cacheData;
    }
    
    /*This is internal method not for calling from outside. Uses the promotion JSON and loads it into Memory*/
    public void parseJsonforfieldValues(string promotionId, string promotionJson){
        String promotionType='';
        List<string> valueAndPromotion = new List<string>();
        System.debug('@@@Promotion JSON: ' + promotionJson);
        Map<string,object> pJson = (Map<string,object>) JSON.deserializeUntyped(promotionJson);
        
        map<string,object> promotionTypeMap = (map<string,object>)pJson.get('promotionType');
        system.debug('@@@Promotion Type: ' + promotionTypeMap);
        if(promotionTypeMap != null){
            promotionType= (String) promotionTypeMap.get('promotionType'); 
            system.debug('promotion type is: ' + promotionType);
            promotionId = promotionId+'_'+promotionType;
        }
        
        map<string,object> fieldsValuesMap = (map<string,object>)pJson.get('fieldValuesList');
        system.debug('@@@Field Values Map: ' + fieldsValuesMap);
        
        List<object> fieldValueString = (List<object>)fieldsValuesMap.get('fieldValues');
        System.debug('@@@Fields Values String: ' + fieldValueString);
        for(object fieldValue: fieldValueString){
            system.debug('@@fieldValueCustom' + fieldValue);
            string stringWithSemiColon = String.ValueOf(fieldValue);
            system.debug('@@strcustom' + stringWithSemiColon);
            /*if(stringWithSemiColon.contains(';') == true){
                system.debug('@@insideIfcustom');
                stringWithSemiColon = stringWithSemiColon.replaceAll(';' , ',');
            }*/
            List<String> fieldValueLst = new List<String>();
            if(stringWithSemiColon.contains(';') == true){
                system.debug('contains');
                fieldValueLst = stringWithSemiColon.split(';');
            }
            else{
                fieldValueLst.add(stringWithSemiColon);
            }
            system.debug('@@@Field Value List: ' + fieldValueLst);
            for(integer i =0; i<fieldValueLst.size();i++){
                String cacheKey =  (String) fieldValueLst [i];
                System.debug('@@@Cache Key: ' +cacheKey );
                new PromotionCacheBuilder(cacheKey ,promotionId);
                cacheKey = cacheKey.deleteWhitespace();
                cacheKey= cacheKey.replaceAll('[|,|.|\\,|\\-|"||:|~|!|@|#|$|%|^|&|*|_|+|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]', '');
                cacheKey = cacheKey.replace('/','');
                cacheKey = cacheKey.replace('\\','');
                cacheKey= cacheKey.toUpperCase();
                cacheKeySet.add(cacheKey);
            }
        }        
    }
}