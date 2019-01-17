/*******************************************************************************************************************
 * Class Name     : CachePromotionValueFetcher
 * Author         : Accenture
 * Date           : 03-Dec-2017
 * Description    : Method to fetch promotions from Cache and invalidate Cache
 ******************************************************************************************************************/
public class CachePromotionValueFetcher{
    
    public static List<WirelinePromoCacheData__c> cacheValueSet = [SELECT cacheKey__c,cacheValue__c FROM WirelinePromoCacheData__c LIMIT 1 ];
    
    /*Invalidate Cache*/
    public static void invalidateCache(){
        try{
            WirelinePromoCacheData__c cacheData = [Select id,cacheKey__c,cacheValue__c from WirelinePromoCacheData__c where  cacheKey__c = 'cacheKeys' limit 1];
            if(cacheData != null){
                String cacheKeys = cacheData.cacheValue__c;
                if(cacheKeys != null){
                    System.debug(' ******** Cache invalidated Starts *********** ');
                    List<String> cacheKeysSet = (List<String>)System.JSON.deserialize(cacheKeys, List<String>.class);
                    for (String cacheKey : cacheKeysSet ) {
                        System.debug(' Keys from Cache : cacheKey  = ['+cacheKey+']');
                        cacheKey = cacheKey.remove('"');
                        Cache.Org.remove(cacheKey);
                    }
                    //Remove miscellaneous keys from the cache
                    if(Cache.Org.get('Promotion') != null) {
                        Cache.Org.remove('Promotion');
                    }
                    if (Cache.Org.get('CacheLoaded') != null) {
                        Cache.Org.remove('CacheLoaded');
                    } 
                    Cache.OrgPartition orgPartition = Cache.Org.getPartition('local.OrgLevel'); 
                    orgPartition.remove(PromotionMetaData.class,'ALLMETADATA');
                    orgPartition.remove(MetaData.class,'ALL');
                    
                    System.debug(' Cache loaded value from the cache = [' + Cache.Org.get('CacheLoaded')+']');
                }
           }
           System.debug('Cache invalidated');
       }catch(Exception ex) {
           System.debug ('CachePromotionValueFetcher : invalidateCache : Somethign went wrong ' + ex);
       }
    }  
    
    /*Fetch Promotions from Cache*/
    public Object get(String value){
        System.debug('look for me: asked from cache for : ' + value);
        value = value.deleteWhitespace();
        value = value.replaceAll('[|,|.|\\,|\\-|\\–|"||:|~|!|@|#|$|%|^|&|*|_|+|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]', '');
        value = value.replace('/','');
        value = value.replace('\\','');
        value = value.toUpperCase();
        Object cacheObj = Cache.Org.get(value);
        
        if(cacheObj == null || cacheObj.equals('')){  
            system.debug('@@@CacheValueSet: '+cacheValueSet);          
            if(String.isNotBlank(cacheValueSet[0].cacheValue__c) && cacheValueSet[0].cacheValue__c != '[]' && cacheValueSet[0].cacheValue__c.replaceAll('[\\[|\\]|\\"]','').split(',').contains(value)){
                system.debug('@@@Data Missing in cache for Key: '+value);                
                //If true, invoke invalidate cache
                CachePromotionValueFetcher.invalidateCache();
                system.debug('Invalidated Cache----------------> executed');
                
                //Restore Promotions
                PromotionCacheFeeder pcf = new PromotionCacheFeeder();
                pcf.feedPromotions();
                system.debug('Promotions Feeder----------------> executed');                
                cacheObj = Cache.Org.get(value);                
            }
        }
        return cacheObj;
    }
}