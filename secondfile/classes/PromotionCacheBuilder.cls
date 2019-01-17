/** 
Class Name: PromotionCacheBuilder
Description: This loads the exploded value map to Cache
Date: 10/25/2017 2:38 PM CDT
Change log:
    Initial Version    : Varun Kumar 
**/
public class PromotionCacheBuilder
{
    string cacheKey;
    List<string> promotionidList;

    /**
     This method adds the promotion to the promotion list and puts it back to Cache. 
    **/
    public PromotionCacheBuilder(string cjs,string promotionid)
    { 
        List<String> promFinalList = new List<String>();  
        Set<String> promFinalSet = new Set<String>();      
        system.debug('cjs is: ' + cjs); 
        //data cannot have data with whitespace and special charaters. if data contains this remove it. 
        cjs = cjs.deleteWhitespace();
        cjs = cjs.replaceAll('[|,|.|\\,|\\-|\\–|"||:|~|!|@|#|$|%|^|&|*|_|+|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'",\\\\]', '');
        cjs = cjs.replace('/','');
        cjs = cjs.replace('\\-','');
        cjs = cjs.replace('\\','');
        cjs = cjs.toUpperCase();
        system.debug('promotionid is: ' + promotionid);
        //if data alerady exists in cache, add to the promotion list, if add the data and promotion list
        promotionidList = (List<string>) Cache.Org.get(cjs);
        if(promotionidList == null){
            system.debug('didnt find this in cache');
            promotionidList = new List<string>();
            promotionidList.add(promotionid);
        }else{
            promotionidList.add(promotionid);
            Cache.Org.remove(cjs);
        }
        if(!promotionidList.isEmpty()){
            promFinalSet.addAll(promotionidList);
            promFinalList.addAll(promFinalSet);
        }        
        system.debug('@@@promotionidList:'+promotionidList);
        system.debug('@@@promFinalSet:'+promFinalSet);
        Cache.Org.put(cjs,promFinalList);
    }    
}