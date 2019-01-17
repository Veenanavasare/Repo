public class PromotionMetaData implements Cache.CacheBuilder
{
    Map<String,Set<String>> metaMap = new Map<String,Set<String>>();
    public Object doLoad(String id)
    {
        List<Wireline_Promo_Meta_Data__c> metaData = [select Id,Before_Apply_Get_Price__c,WP_Configurator_Name__c,WP_Field_API_Name__c,WP_Field_Name__c,WP_Field_Value__c,WP_Object_API_Name__c,WP_Promo_Type__c,WP_Requires_Input__c,WP_Section_Name__c,WP_Section_Order__c from Wireline_Promo_Meta_Data__c];
        for ( Wireline_Promo_Meta_Data__c mData : metaData )
        {
            Set<String> metaFieldSet = metaMap.get(mData.WP_Object_API_Name__c);
            if (metaFieldSet == null)
            {
                metaFieldSet = new Set<String>();
            }
            metaFieldSet.add(mData.WP_Field_API_Name__c);
            metaMap.put(mData.WP_Object_API_Name__c,metaFieldSet);
        }
        
        return metaMap;        
    }
}